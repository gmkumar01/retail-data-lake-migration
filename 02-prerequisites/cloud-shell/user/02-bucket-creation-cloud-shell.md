# About
This module includes all the steps for creating GCS bucket to store the scripts and input data files for the usecase <br>

[1. Declare variables](02-bucket-creation-cloud-shell.md#1-declare-variables) <br>
[2. GCS Bucket creation](02-bucket-creation-cloud-shell.md#2-gcs-bucket-creation) <br>

## 0. Prerequisites
Please note down both gcp associated Project IDs. Assume one as an on-premises environment and other as google cloud environment, as we are going to address them accordingly throughout the lab.

#### 1. Create a new project or select an existing project.
Note down the gcloud project number and project ID.

#### 2. Activate Cloud Shell.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com) <br>

Run the below command to set the project to cloud shell terminal:
```
gcloud config set project <your_gcloud_project_id>
```

## 1. Declare variables
We will use these throughout the lab. 
```
# Not required if you have declared all variables from '01-network-creation-cloud-shell'

REGION=<region_where_resources_will_be_created>
GOOG_PROJECT_ID=$(gcloud config get-value project)
GOOG_STAGING_BUCKET=$USER-<your_gcloud_staging_bucket_name>
GOOG_STORAGE_BUCKET=$USER-<your_gcloud_storage_bucket_name>
GOOG_METASTORE_BUCKET=$USER-<your_gcloud_metastore_bucket_name>
```

## 2. GCS Bucket creation
Run the following gsutil command in Cloud Shell to create the required buckets.
```
gsutil mb -p $GOOG_PROJECT_ID -c STANDARD -l $REGION gs://$GOOG_STORAGE_BUCKET
gsutil mb -p $GOOG_PROJECT_ID -c STANDARD -l $REGION gs://$GOOG_STAGING_BUCKET
gsutil mb -p $GOOG_PROJECT_ID -c STANDARD -l $REGION gs://$GOOG_METASTORE_BUCKET
```