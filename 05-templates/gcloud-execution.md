# About

In this module contains the execution instruction to migrate the hadoop infrastructure to google cloud.

Following are the lab modules:

[1. Declaring Variables](gcloud-execution.md#1-declaring-variables)<br>
[2. Migrate Data, Jobs and Warehouse through Cloud Shell](gcloud-execution.md#2-migrate-data-jobs-and-warehouse-through-cloud-shell)<br>
[3. Logs](gcloud-execution.md#3-logs)<br>
[4. Import Hive Metadata to Dataproc Metastore](gcloud-execution.md#4-import-hive-metadata-to-dataproc-metastore)<br>
[5. Set/Alter External Hive Tables location to google storage bucket](gcloud-execution.md#5-setalter-external-hive-tables-location-to-google-storage-bucket)<br>
[6. Verify the tables](gcloud-execution.md#6-verify-the-tables)<br>
[7. Run a oozie job](gcloud-execution.md#7-run-a-oozie-job)<br>

## 0. Prerequisites 
Please note down both gcp associated Project IDs. Assume one as an on-premises environment and other as google cloud environment, as we are going to address them accordingly throughout the lab.

#### 1. Create a new project or select an existing project.
Note down the on-premises project number and project ID.

#### 2. Attach cloud shell to your project.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com). <br>
Run the below command to set the project to cloud shell terminal:
```
gcloud config set project your.on.prem.project.id
```

## 1. Declaring Variables
Based on the prereqs and checklist, declare the following variables in cloud shell by replacing with your values:

```
# Not required if the resources are created using terraform

GOOG_PROJECT_ID=<your_google_project_id>
REGION=<your_region_where_resources_are_being_created>
ZONE=<your_zone_where_resources_are_being_created>
ON_PREM_PROJECT_ID=$(gcloud config get-value project)
ON_PREM_PROJECT_NUM=$(gcloud projects list --filter="$ON_PREM_PROJECT_ID" --format="value(PROJECT_NUMBER)")
ON_PREM_STORAGE_BUCKET=<your_on_prem_storage_bucket_name>
ON_PREM_CLUSTER=<your_on_prem_cluster_name>
GOOG_CLUSTER=$USER-<your_gcloud_cluster_name>
GOOG_METASTORE=$USER-<your_gcloud_metastore_service_name>
GOOG_STORAGE_BUCKET=$USER-<your_gcloud_storage_bucket_name>
GOOG_METASTORE_BUCKET=$USER-<your_gcloud_metastore_bucket_name>
HOSTNAME=$GOOG_CLUSTER-m
```

**Note:** Please ensure to use the values provided by the admin team where they are required.

#### 1.1. Update Cloud Shell SDK version
Run the below on cloud shell:
```
gcloud components update
```

#### 1.2. Set Region and Zone
Run the below command on cloud shell:
```
gcloud config set dataproc/region your.region
```

## 2. Migrate Data, Jobs and Warehouse through Cloud Shell

#### 2.1 Run below on cloud shell to provide access control to gcs buckets
```
# Provides access control permission to user on service account for cross project bucket access for specified buckets.

gsutil -m acl ch -u your.on.prem.project.num-compute@developer.gserviceaccount.com:W gs://your.gcloud.storage.bucket.name/;
gsutil -m acl ch -u your.on.prem.project.num-compute@developer.gserviceaccount.com:W gs://your.gcloud.metastore.bucket.name/;
```

#### 2.2 Running Hadoop Job run below commands in the cloud shell
Run the following command in cloud shell:

```
gcloud dataproc jobs submit hadoop \
    --cluster your.on.prem.cluster.name \
    --id $USER-mapreduce-dlm-$RANDOM \
    --class=org.apache.hadoop.tools.DistCp -- gs://your.on.prem.storage.bucket.name/* gs://your.gcloud.storage.bucket.name/
```

#### 2.3 Copy the warehouse data to metastore bucket

```
gsutil mv -r gs://your.gcloud.storage.bucket.name/dlm-poc/hive-data/* gs://your.gcloud.metastore.bucket.name/hive_warehouse
```

## 3. Logs

#### Dataproc Jobs Logs

Once you submit the job, you can see the job run under *Dataproc* > *Jobs* as shown below:

![this is a screenshot](/images/dataproc_logs.png)

## 4. Import Hive Metadata to Dataproc Metastore
```
gcloud config set project your.google.project.id
```

```
gcloud metastore services import gcs your.gcloud.metastore.service.name \
    --location your.region \
    --import-id=$USER-hive-metastore-dlm-$RANDOM \
    --dump-type=mysql --database-dump gs://your.gcloud.storage.bucket.name/hivedump.sql
```

**Note - it takes few minutes to update the metastore**

## 5. Set/Alter External Hive Tables location to google storage bucket

#### 5.1. Connect to cluster through SSH

```
gcloud compute ssh your.gcloud.cluster.name-m --project your.google.project.id --zone your.zone
```

#### 5.2. Now connect to beeline interface to set new location to external tables

Declare Variable
```
# declare the variables again

GOOG_CLUSTER=your.gcloud.cluster.name
GOOG_STORAGE_BUCKET=your.gcloud.storage.bucket.name
```
Run below to connec to beeline interface to run hive queries
```
beeline -u "jdbc:hive2://your.gcloud.cluster.name-m:10000"
```
To set table location run below in cloud shell
```
# Replace your respective bucket names in place of <your_gcloud_storage_bucket> and <your_gcloud_metastore_bucket>.

alter table aisles set location 'gs://your.gcloud.storage.bucket.name/retail-data-lake-migration/01-datasets/aisles';
alter table orders set location 'gs://your.gcloud.storage.bucket.name/retail-data-lake-migration/01-datasets/orders';
alter table departments set location 'gs://your.gcloud.storage.bucket.name/retail-data-lake-migration/01-datasets/departments';
alter table products set location 'gs://your.gcloud.storage.bucket.name/retail-data-lake-migration/01-datasets/products';
alter table dim_aisle set location 'gs://your.gcloud.metastore.bucket.name/hive_warehouse/dim_aisle';
alter table fact_order set location 'gs://your.gcloud.metastore.bucket.name/hive_warehouse/fact_order';
alter table dim_department set location 'gs://your.gcloud.metastore.bucket.name/hive_warehouse/dim_department';
alter table dim_product set location 'gs://your.gcloud.metastore.bucket.name/hive_warehouse/dim_product';
```


## 6. Verify the tables

To verify the table data run the below command:
```
# Replace <table_name> with respective table name

select * from <table_name> limit 10;
```

To see the table properties and location run the below:
```
# Replace <table_name> with respective table name

show create table <table_name>;

# exit beeline

!quit
```

## 7. Run a oozie job

Run the below command to copy the oozie job files into the master node of the cluster
```
hdfs dfs -get gs://your.gcloud.storage.bucket.name/retail-data-lake-migration/00-scripts-and-config/oozie ~/
```

Run the below sed command to replace USER_ID with your user id in the oozie job properties file.
```
sed -i "s/USER_ID/${USER}/g" ~/oozie/shell_py/job.properties
sed -i "s/namenode/your.gcloud.cluster.name/g" ~/oozie/shell_py/job.properties
```

Run the below command to copy the oozie job files into the hdfs of the cluster
```
hdfs dfs -put ~/ /user/${whoami}/
```

Run the below command to submit the oozie job
```
oozie job -oozie http://your.gcloud.cluster.name-m:11000/oozie -config ~/oozie/shell_py/job.properties -run
```

After running oozie successfully exit the cluster using exit command.<br>

To monitor the job status and to check the logs, we can use the oozie web UI. To open Web UI follow the below steps:<br>

Open Google Cloud Cloud Shell. 

Run the gcloud command, below, in Cloud Shell to set up an SSH tunnel from a Cloud Shell preview port to a web interface port on the master node on your cluster.
```
gcloud compute ssh your.gcloud.cluster.name-m   --project=your.google.project.id --zone=your.zone  --   -4 -N -L 8080:your.gcloud.cluster.name-m:11000
```

Click the Cloud Shell Web Preview button web-preview-button, and then select "Preview on port 8080". And Click Done Jobs to view the status of the oozie job.