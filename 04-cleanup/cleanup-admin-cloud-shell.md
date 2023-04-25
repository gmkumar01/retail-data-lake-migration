# About

This module includes the steps to cleanup the resources created for the retail data lake migration usecase using cloud shell commands.

[1. Declare variables](cleanup-admin-cloud-shell.md#1-declare-variables)<br>
[2. Delete Dataproc Cluster](cleanup-admin-cloud-shell.md#2-delete-the-dataproc-cluster)<br>
[3. Delete GCS Buckets](cleanup-admin-cloud-shell.md#3-delete-gcs-buckets)<br>
[4. Delete SQL instance](cleanup-admin-cloud-shell.md#4-delete-sql-instance)<br>
[5. Delete VPC network](cleanup-admin-cloud-shell.md#5-delete-vpc-network)<br>

## 0. Prerequisites
Please note down both gcp associated Project IDs. Assume one as an on-premises environment and other as google cloud environment, as we are going to address them accordingly throughout the lab.

#### 1. GCP Project Details
Note down the on-premises project number and project ID as we will need this for the the cleanup process

#### 3. Attach cloud shell to your project.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com) <br>
Run the below command to set the project in the cloud shell terminal:

```
gcloud config set project <your_on_prem_project_id>
```

## 1. Declare variables 

Run the below in cloud shells coped to the project you selected-

```
REGION=<region_where_resources_will_be_created>
ZONE=<zone_where_resources_will_be_created>
VPC=<your_vpc_name>
ON_PREM_PROJECT_ID=$(gcloud config get-value project)
ON_PREM_STORAGE_BUCKET=<your_on_prem_storage_bucket_name>
ON_PREM_METASTORE=<your_on_prem_metastore_name>
ON_PREM_CLUSTER=<your_on_prem_cluster_name>
ON_PREM_STAGING_BUCKET=<your_on_prem_staging_bucket_name>
```

## 2. Delete the Dataproc Cluster

Run the below command to delete the Dataproc cluster

```
gcloud dataproc clusters delete $ON_PREM_CLUSTER --region $REGION --project $ON_PREM_PROJECT_ID
```

## 3. Delete GCS Buckets

Follow the commands to delete the following buckets 
* Bucket serving as code and data files storage location and hive warehouse
* Bucket attached to Dataproc clusters as staging bucket

```
gsutil rm -r gs://$ON_PREM_STAGING_BUCKET;
gsutil rm -r gs://$ON_PREM_STORAGE_BUCKET;
```

## 4. Delete SQL Instance

Run below command to delete the sql instance

```
gcloud sql instances delete $ON_PREM_METASTORE
```

## 5. Delete VPC Network

Paste the following command in the shell.

```
gcloud compute networks delete $VPC
```