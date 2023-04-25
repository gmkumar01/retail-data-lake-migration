# About

This module includes the steps to cleanup the resources created for the retail data lake migration usecase using cloud shell commands.

[1. Declare variables](cleanup-user-cloud-shell.md#1-declare-variables)<br>
[2. Delete Dataproc Cluster](cleanup-user-cloud-shell.md#2-delete-the-dataproc-cluster)<br>
[3. Delete the Metastore service](cleanup-user-cloud-shell.md#3-delete-metastore-service)<br>
[4. Delete GCS Buckets](cleanup-user-cloud-shell.md#4-delete-gcs-buckets)<br>
[5. Delete VPC network](cleanup-user-cloud-shell.md#5-delete-vpc-network)<br>

## 0. Prerequisites
Please note down both gcp associated Project IDs. Assume one as an on-premises environment and other as google cloud environment, as we are going to address them accordingly throughout the lab.

#### 1. GCP Project Details
Note down the gcloud project ID as we will need this for the the cleanup process

#### 3. Attach cloud shell to your project.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com) <br>
Run the below command to set the project in the cloud shell terminal:

```
gcloud config set project <your_gcloud_project_id>
```

## 1. Declare variables 

Run the below in cloud shells coped to the project you selected-

```
GOOG_PROJECT_ID=$(gcloud config get-value project)
REGION=<region_where_resources_will_be_created>
ZONE=<zone_where_resources_will_be_created>
VPC=$USER-<your_vpc_name>
GOOG_CLUSTER=$USER-<your_gcloud_cluster_name>
GOOG_METASTORE=$USER-<your_gcloud_metastore_service_name>
GOOG_STAGING_BUCKET=$USER-<your_gcloud_staging_bucket_name>
GOOG_STORAGE_BUCKET=$USER-<your_gcloud_storage_bucket_name>
GOOG_METASTORE_BUCKET=$USER-<your_gcloud_metastore_bucket_name>
```

## 2. Delete the Dataproc Cluster

Run the below command to delete the Dataproc cluster

```
gcloud dataproc clusters delete $GOOG_CLUSTER --region=$REGION --project $GOOG_PROJECT_ID
```

## 3. Delete metastore service

Run the below command to delete metastore service
```
gcloud metastore services delete projects/$GOOG_PROJECT_ID/locations/$REGION/services/$GOOG_METASTORE
```

## 4. Delete GCS Buckets

Follow the commands to delete the following buckets 
* Bucket serving as code and data files storage location
* Bucket attached to Dataproc cluster as staging bucket
* Bucket attached to metastore service as warehouse bucket

```
gsutil rm -r gs://$GOOG_STAGING_BUCKET
gsutil rm -r gs://$GOOG_STORAGE_BUCKET
gsutil rm -r gs://$GOOG_METASTORE_BUCKET
```

## 5. Delete VPC Network

Run the below command to delete vpc network

```
gcloud compute networks delete $VPC
```