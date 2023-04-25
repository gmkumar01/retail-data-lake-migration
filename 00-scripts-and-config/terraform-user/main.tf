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

/***********************************
Local variables declaration
***********************************/
locals {
  user_id                     = "${var.user_id}"
  project_id                  = "${var.project_id}"
  location                    = <region_where_resources_will_be_created>
  zone                        = <zone_where_resources_will_be_created>
  vpc_nm                      = ${local.user_id}-<your_vpc_network_name>
  subnet_nm                   = ${local.user_id}-<your_subnet_name>
  subnet_cidr                 = <your_subnet_cidr> # Example: "10.0.0.0/16"
  firewall_nm                 = ${local.user_id}-<your_firewall_name>
  goog_dp_cluster             = ${local.user_id}-<your_cluster_name>
  dp_metastore_nm             = ${local.user_id}-<your_metastore_service_name>
  dp_metastore_bucket         = ${local.user_id}-<your_metastore_bucket_name>
  goog_staging_bucket         = ${local.user_id}-<your_cluster_staging_bucket_name>
  goog_storage_bucket         = ${local.user_id}-<your_storage_bucket_name>
  warehouse_bucket            = <on_prem_storage_bucket_name>
  on_prem_cluster             = <on_prem_cluster_name>
}

/******************************************
 GOOGLE CLOUD RESOURCES
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

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/
resource "time_sleep" "sleep_after_vpc_creation" {
  create_duration = "10s"
  depends_on = [
    google_compute_firewall.allow_intra_snet_ingress_to_any
  ]
}

/******************************************
3. Bucket creation
*****************************************/
 /*GCS STAGING BUCKETS*/
resource "google_storage_bucket" "goog_staging_bucket" {
  project       = local.project_id
  name          = local.goog_staging_bucket
  location      = local.location
  force_destroy = true
  depends_on    = [
    time_sleep.sleep_after_vpc_creation
  ]
}
/*Storage Bucket Creation*/
resource "google_storage_bucket" "goog_storage_bucket" {
  project       = local.project_id
  name          = local.goog_storage_bucket
  location      = local.location
  force_destroy = true
    depends_on    = [
    time_sleep.sleep_after_vpc_creation
  ]
}
/*Dataproc Metastore Bucket Creation*/
resource "google_storage_bucket" "dp_metastore_bucket" {
  project       = local.project_id
  name          = local.dp_metastore_bucket
  location      = local.location
  force_destroy = true
    depends_on    = [
    time_sleep.sleep_after_vpc_creation
  ]
}

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/
resource "time_sleep" "sleep_after_bucket_creation" {
  create_duration = "10s"
  depends_on = [
    google_storage_bucket.goog_storage_bucket,
    google_storage_bucket.goog_staging_bucket,
    google_storage_bucket.dp_metastore_bucket
  ]
}

/******************************************
4. Metastore creation
*****************************************/

/*DATAPROC METASTORE*/
resource "google_dataproc_metastore_service" "hive_metastore" {
  project          = local.project_id
  service_id       = local.dp_metastore_nm
  location         = local.location
  network          = "projects/${local.project_id}/global/networks/${local.vpc_nm}"
  hive_metastore_config {
    version = "3.1.2"
    config_overrides = {
        "hive.metastore.warehouse.dir" = "gs://${local.dp_metastore_bucket}/hive_warehouse"
    }
  }
  depends_on = [
    time_sleep.sleep_after_bucket_creation
  ]
}

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/

resource "time_sleep" "sleep_after_metastore_creation" {
  create_duration = "60s"
  depends_on = [
    google_dataproc_metastore_service.hive_metastore
  ]
}

/******************************************
5. Cluster creation
*****************************************/

/*GOOG DATAPROC CLUSTER*/
resource "google_dataproc_cluster" "goog_dp_cluster_creation" {
  provider = google-beta
  project  = local.project_id
  name     = "${local.goog_dp_cluster}"
  region   = local.location

  cluster_config {
    staging_bucket = "${local.goog_staging_bucket}"
    gce_cluster_config{
      zone     = local.zone
      subnetwork = "projects/${local.project_id}/regions/${local.location}/subnetworks/${local.subnet_nm}"
    }
    initialization_action {
      script      = "gs://goog-dataproc-initialization-actions-${local.location}/oozie/oozie.sh"
    }
    metastore_config {
      dataproc_metastore_service = "projects/${local.project_id}/locations/${local.location}/services/${local.dp_metastore_nm}"
    }
  }
  depends_on = [
    time_sleep.sleep_after_metastore_creation
  ]
}

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/

resource "time_sleep" "sleep_after_goog_dp_cluster_creation" {
  create_duration = "5s"
  depends_on = [
    google_dataproc_cluster.goog_dp_cluster_creation
  ]
}

/******************************************
6. Customize Scripts
*****************************************/

resource "null_resource" "gcloud-execution-file-update" {
    provisioner "local-exec" {
        command = "cp ../../05-templates/gcloud-execution.md ../../03-execution-instructions/ && sed -i s/your.google.project.id/${local.project_id}/g ../../03-execution-instructions/gcloud-execution.md && sed -i s/your.region/${local.location}/g ../../03-execution-instructions/gcloud-execution.md && sed -i s/your.zone/${local.zone}/g ../../03-execution-instructions/gcloud-execution.md && sed -i s/your.on.prem.storage.bucket.name/${local.warehouse_bucket}/g ../../03-execution-instructions/gcloud-execution.md && sed -i s/your.on.prem.cluster.name/${local.on_prem_cluster}/g ../../03-execution-instructions/gcloud-execution.md && sed -i s/your.gcloud.cluster.name/${local.goog_dp_cluster}/g ../../03-execution-instructions/gcloud-execution.md && sed -i s/your.gcloud.metastore.service.name/${local.dp_metastore_nm}/g ../../03-execution-instructions/gcloud-execution.md && sed -i s/your.gcloud.storage.bucket.name/${local.goog_storage_bucket}/g ../../03-execution-instructions/gcloud-execution.md && sed -i s/your.gcloud.metastore.bucket.name/${local.dp_metastore_bucket}/g ../../03-execution-instructions/gcloud-execution.md && sed -i s/your.on.prem.project.id/${var.on_prem_project_id}/g ../../03-execution-instructions/gcloud-execution.md && sed -i s/your.on.prem.project.num/${var.on_prem_project_num}/g ../../03-execution-instructions/gcloud-execution.md "
        interpreter = ["bash", "-c"]
    }
}