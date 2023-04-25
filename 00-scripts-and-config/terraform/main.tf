/*
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/******************************************
Local variables declaration
*****************************************/

locals {
  project_id                  = "${var.project_id}"
  project_num                 = "${var.project_nbr}"
  location                    = <region_where_resources_will_be_created>
  zone                        = <zone_where_resources_will_be_created>
  warehouse_bucket            = <your_on_prem_storage_bucket_name>
  on_prem_staging_bucket      = <your_on_prem_cluster_staging_bucket_name>
  sql_instance                = <your_on_prem_metastore_name>
  on_prem_cluster             = <your_on_prem_cluster_name>
  vpc_nm                      = <your_vpc_name>
  subnet_nm                   = <your_subnet_name>
  subnet_cidr                 = <your_subnet_cidr> #Example: "10.0.0.0/16"
  firewall_nm                 = <your_firewall_name>
}

/******************************************
 ON-PREM RESOURCES
*****************************************/

/******************************************
1. VPC Network & Subnet Creation
 *****************************************/
module "vpc_creation" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 4.0"
  project_id                             = "${local.project_id}"
  network_name                           = "${local.vpc_nm}"
  routing_mode                           = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${local.subnet_nm}"
      subnet_ip             = "${local.subnet_cidr}"
      subnet_region         = "${local.location}"
      subnet_range          = "${local.subnet_cidr}"
      subnet_private_access = true
    }
  ]
}

/******************************************
2. Firewall rules creation
 *****************************************/

resource "google_compute_firewall" "allow_intra_snet_ingress_to_any" {
  project   = "${local.project_id}"
  name      = "${local.firewall_nm}"
  network   = "${local.vpc_nm}"
  direction = "INGRESS"
  source_ranges = [local.subnet_cidr]
  allow {
    protocol = "all"
  }
  description        = "Creates firewall rule to allow ingress from within subnet on all ports, all protocols"
  depends_on = [
    module.vpc_creation
  ]
}

/******************************************
3. Storage bucket creation
*****************************************/
 /*GCS BUCKETS*/
resource "google_storage_bucket" "on_prem_staging_bucket" {
  project       = "${local.project_id}"
  name          = local.on_prem_staging_bucket
  location      = local.location
  force_destroy = true
  depends_on = [
    google_compute_firewall.allow_intra_snet_ingress_to_any
  ]
}

/*GCS WAREHOUSE BUCKET*/
resource "google_storage_bucket" "warehouse_bucket" {
  project       = "${local.project_id}"
  name          = local.warehouse_bucket
  location      = local.location
  force_destroy = true
  depends_on = [
    google_compute_firewall.allow_intra_snet_ingress_to_any
  ]
}

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/
resource "time_sleep" "sleep_after_bucket_creation" {
  create_duration = "10s"
  depends_on = [
    google_storage_bucket.on_prem_staging_bucket,
    google_storage_bucket.warehouse_bucket
  ]
}

/******************************************
4. CLOUD SQL INSTANCE
*****************************************/

/*ON PREM HIVE WAREHOUSE*/
resource "google_sql_database_instance" "hive_metastore_creation" {
  project             = "${local.project_id}"
  name                = local.sql_instance
  database_version    = "MYSQL_5_7"
  region              = local.location
  deletion_protection = false
  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
    activation_policy = "ALWAYS"
    location_preference {
      zone  = local.zone
    }
  }
  depends_on = [
    time_sleep.sleep_after_bucket_creation
  ]
}

/*CREATING USER*/
resource "google_sql_user" "users" {
  name = "root"
  instance = local.sql_instance
  host = "%"
  password = ""
  depends_on = [
    time_sleep.sleep_after_hive_metastore_creation
  ]
}

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/

resource "time_sleep" "sleep_after_hive_metastore_creation" {
  create_duration = "60s"
  depends_on = [
      google_sql_database_instance.hive_metastore_creation
  ]
}

/******************************************
5. Cluster creation
*****************************************/

 /*ON PREM DATAPROC CLUSTER*/
resource "google_dataproc_cluster" "on_prem_cluster_creation" {
  provider = google-beta
  project  = "${local.project_id}"
  name     = local.on_prem_cluster
  region   = local.location

  cluster_config {
    staging_bucket = local.on_prem_staging_bucket
    gce_cluster_config{
      zone     = local.zone
      service_account_scopes = ["sql-admin"]
      subnetwork = "projects/${local.project_id}/regions/${local.location}/subnetworks/${local.subnet_nm}"
      metadata = {
        "hive-metastore-instance" = "${local.project_id}:${local.location}:${local.sql_instance}"
      }
    }
    initialization_action {
      script = "gs://goog-dataproc-initialization-actions-${local.location}/cloud-sql-proxy/cloud-sql-proxy.sh"
    }
    software_config{
      optional_components = ["JUPYTER"]
      override_properties = {
        "hive:hive.metastore.warehouse.dir" = "gs://${local.warehouse_bucket}/dlm-poc/hive-data"
      }
    }
    endpoint_config{
      enable_http_port_access = "true"
    }
  }
  depends_on = [
    time_sleep.sleep_after_hive_metastore_creation
  ]
}

/******************************************
3. Copying files to GCS
*****************************************/

/*UPLOAD FOLDERS TO GCS*/
resource "null_resource" "upload_folder_content" {
 provisioner "local-exec" {
   command = "gsutil cp -r ../../../retail-data-lake-migration/* gs://${local.warehouse_bucket}/retail-data-lake-migration/"
  }
  depends_on = [
   google_dataproc_cluster.on_prem_cluster_creation
  ]
}

/******************************************
5. DATAPROC JOB SUBMIT
*****************************************/

/*HIVE TABLE CREATION*/
resource "google_dataproc_job" "hive" {
  region       = google_dataproc_cluster.on_prem_cluster_creation.region
  force_delete = true
  placement {
    cluster_name = google_dataproc_cluster.on_prem_cluster_creation.name
  }
  hive_config {
    query_list = [
      "create external table aisles(aisle_id int,aisle string) row format delimited fields terminated by '|' stored as textfile location 'gs://${local.warehouse_bucket}/retail-data-lake-migration/01-datasets/aisles' ",
      "create external table orders(order_id int, user_id int, eval_set string, order_number int, order_dow int,order_hour_of_day int, days_since_prior_order int) row format delimited fields terminated by '|' stored as textfile location 'gs://${local.warehouse_bucket}/retail-data-lake-migration/01-datasets/orders' ",
      "create external table products(product_id int,product_name string,aisle_id int, department_id int) row format delimited fields terminated by '|' stored as textfile location 'gs://${local.warehouse_bucket}/retail-data-lake-migration/01-datasets/products' ",
      "create external table departments(department_id int,department_name string) row format delimited fields terminated by '|' stored as textfile location 'gs://${local.warehouse_bucket}/retail-data-lake-migration/01-datasets/departments' ",
      "create table dim_aisle (id int not null, aisle_name string, insert_dttm timestamp, insert_by string) row format delimited fields terminated by '|' ",
      "create table fact_order (order_id int not null, user_id int not null,  order_number int not null, order_hour_of_day int, days_since_prior_order int, order_date date ,insert_dttm timestamp, insert_by string) row format delimited fields terminated by '|' ",
      "create table dim_product(product_id int not null,product_name string,aisle_id int not null, department_id int not null, insert_dttm timestamp,insert_by string) row format delimited fields terminated by '|' ",
      "create table dim_department(department_id int not null,department string, insert_dttm timestamp,insert_by string) row format delimited fields terminated by '|' ",
    ]
  }
  depends_on = [
    null_resource.upload_folder_content
  ]
}

/*APPEND DATA TO MANAGED TABLES*/
resource "google_dataproc_job" "pyspark" {
  region       = google_dataproc_cluster.on_prem_cluster_creation.region
  force_delete = true
  placement {
    cluster_name = google_dataproc_cluster.on_prem_cluster_creation.name
  }
  pyspark_config {
    main_python_file_uri = "gs://${local.warehouse_bucket}/retail-data-lake-migration/00-scripts-and-config/oozie/shell_py/bin/pyspark_job.py"
    properties = {
      "spark.logConf" = "true"
    }
  }
  depends_on = [
    google_dataproc_job.hive
  ]
}

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/

resource "time_sleep" "sleep_after_job_submission" {
  create_duration = "20s"
  depends_on = [
      google_dataproc_job.pyspark
  ]
}

/******************************************
6. EXPORT SQL DATABASE TO GCS
*****************************************/

resource "null_resource" "export_hive_database" {
  provisioner "local-exec" {
    command = "gsutil acl ch -u $(gcloud sql instances describe ${local.sql_instance} --project=${local.project_id} --format='value(serviceAccountEmailAddress)'):W gs://${local.warehouse_bucket}; gcloud sql export sql ${local.sql_instance} gs://${local.warehouse_bucket}/hivedump.sql --database=hive_metastore;"
  }
  depends_on = [
    time_sleep.sleep_after_job_submission
  ]
}

/*END OF FILE*/