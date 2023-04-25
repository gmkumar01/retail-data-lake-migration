# About

In this module contains the execution instruction to create required tables for this lab.

Following are the lab modules:

[1. The Datasets used for this Project](05-tables-creation-and-export-metadata-cloud-shell.md#1-the-datasets-used-for-this-project)<br>
[2. Declaring Variables](05-tables-creation-and-export-metadata-cloud-shell.md#2-declaring-variables)<br>
[3. Submit the hive jobs on Dataproc Cluster](05-tables-creation-and-export-metadata-cloud-shell.md#3-submit-the-hive-jobs-on-dataproc-cluster)<br>
[4. Submit Pyspark Job on Dataproc Cluster](05-tables-creation-and-export-metadata-cloud-shell.md#4-submit-pyspark-job-on-dataproc-cluster)<br>
[5. Logging](05-tables-creation-and-export-metadata-cloud-shell.md#5-logging)<br>
[6. Export Metadata](05-tables-creation-and-export-metadata-cloud-shell.md#6-export-metadata)

## 0. Prerequisites 
Please note down both gcp associated Project IDs. Assume one as an on-premises environment and other as google cloud environment, as we are going to address them accordingly throughout the lab.

#### 1. Create a new project or select an existing project.
Note down the on-premises project number and project ID.

#### 2. Attach cloud shell to your project.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com). <br>
Run the below command to set the project to cloud shell terminal:
```
gcloud config set project $ON_PREM_PROJECT_ID
```

## 1. The Datasets used for this Project

1.[aisles.csv](01-datasets/aisles/aisles.csv) <br>
2.[orders.csv](01-datasets/orders/orders.csv) <br>
3.[products.csv](01-datasets/products/products.csv) <br>
4.[departments.csv](01-datasets/departments/departments.csv) <br>

**Model Pipeline**

The model pipeline involves the following steps: <br>
- Create external tables and managed tables by submitting hive jobs <br>
- Running pyspark job to append data into managed tables <br>
- Verify table data <br>
- Export Metadata from a managed database

## 2. Declaring Variables

#### 2.1 Set the PROJECT ID in Cloud Shell

Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com)<br>
Run the below

```
gcloud config set project $ON_PREM_PROJECT_ID
```

####  2.2 Declare the variables

Based on the prereqs and checklist, declare the following variables in cloud shell by replacing with your values:

```
# Not required if you have declared all variables from '01-gcp-prerequisites-cloud-shell'

REGION=<region_where_resources_will_be_created>
ZONE=<zone_where_resources_will_be_created>
SUBNET=<your_subnet_name>
ON_PREM_PROJECT_ID=$(gcloud config get-value project)
ON_PREM_PROJECT_NUM=$(gcloud projects list --filter="$ON_PREM_PROJECT_ID" --format="value(PROJECT_NUMBER)")
ON_PREM_STORAGE_BUCKET=<your_on_prem_storage_bucket_name>
ON_PREM_CLUSTER=<your_on_prem_cluster_name>
ON_PREM_METASTORE=<your_on_prem_metastore_name>
```

#### 2.4 Update Cloud Shell SDK version

Run the below on cloud shell

```
gcloud components update
```

#### 2.5 Set Region and Zone

Run the below command on cloud shell
```
gcloud config set dataproc/region $REGION
```

## 3. Submit the hive jobs on Dataproc Cluster

Execute the following gcloud commands in cloud shell to create external and managed hive tables.

**Creating External Hive Tables**

#### 1. AISLES table
```
gcloud dataproc jobs submit hive \
    --cluster $ON_PREM_CLUSTER \
    --execute "create external table aisles(aisle_id int,aisle string) row format delimited fields terminated by '|' stored as textfile location 'gs://$ON_PREM_STORAGE_BUCKET/retail-data-lake-migration/01-datasets/aisles' "
```

#### 2. ORDERS table
```
gcloud dataproc jobs submit hive \
    --cluster $ON_PREM_CLUSTER \
    --execute "create external table orders(order_id int, user_id int, eval_set string, order_number int, order_dow int,order_hour_of_day int, days_since_prior_order int) row format delimited fields terminated by '|' stored as textfile location 'gs://$ON_PREM_STORAGE_BUCKET/retail-data-lake-migration/01-datasets/orders' "
```

#### 3. PRODUCTS table
```
gcloud dataproc jobs submit hive \
    --cluster $ON_PREM_CLUSTER \
    --execute "create external table products(product_id int,product_name string,aisle_id int, department_id int) row format delimited fields terminated by '|' stored as textfile location 'gs://$ON_PREM_STORAGE_BUCKET/retail-data-lake-migration/01-datasets/products' "
```

#### 4. DEPARTMENTS table
```
gcloud dataproc jobs submit hive \
    --cluster $ON_PREM_CLUSTER \
    --execute "create external table departments(department_id int,department_name string) row format delimited fields terminated by '|' stored as textfile location 'gs://$ON_PREM_STORAGE_BUCKET/retail-data-lake-migration/01-datasets/departments' "
```

**Creating Managed Hive Tables**

#### 1. DIM_AISLE table
```
gcloud dataproc jobs submit hive \
    --cluster $ON_PREM_CLUSTER \
    --execute "create table dim_aisle (id int not null, aisle_name string, insert_dttm timestamp, insert_by string) row format delimited fields terminated by '|' "
```

#### 2. FACT_ORDER table
```
gcloud dataproc jobs submit hive \
    --cluster $ON_PREM_CLUSTER \
    --execute "create table fact_order (order_id int not null, user_id int not null,  order_number int not null, order_hour_of_day int, days_since_prior_order int, order_date date ,insert_dttm timestamp, insert_by string) row format delimited fields terminated by '|' "
```

#### 3. DIM_PRODUCT table
```
gcloud dataproc jobs submit hive \
    --cluster $ON_PREM_CLUSTER \
    --execute "create table dim_product(product_id int not null,product_name string,aisle_id int not null, department_id int not null, insert_dttm timestamp,insert_by string) row format delimited fields terminated by '|' "
```

#### 4.DIM_DEPARTMENT table
```
gcloud dataproc jobs submit hive \
    --cluster $ON_PREM_CLUSTER \
    --execute "create table dim_department(department_id int not null,department string, insert_dttm timestamp,insert_by string) row format delimited fields terminated by '|' "
```

## 4. Submit Pyspark Job on Dataproc Cluster
```
gcloud dataproc jobs submit pyspark gs://$ON_PREM_STORAGE_BUCKET/retail-data-lake-migration/00-scripts-and-config/oozie/shell_py/bin/pyspark_job.py \
    --cluster $ON_PREM_CLUSTER
```

## 5. Logging

#### Dataproc Jobs Logs

Once you submit the job, you can see the job log under *Dataproc* > *Jobs* as shown below:

![this is a screenshot](/images/dataproc_logs.png)

## 6. Export Metadata

Run below command in the cloud shell
```
gsutil acl ch -u $(gcloud sql instances describe ${ON_PREM_METASTORE} --project=${ON_PREM_PROJECT_ID} --format="value(serviceAccountEmailAddress)"):W gs://${ON_PREM_STORAGE_BUCKET};
gcloud sql export sql $ON_PREM_METASTORE gs://$ON_PREM_STORAGE_BUCKET/hivedump.sql --database=hive_metastore;
```
