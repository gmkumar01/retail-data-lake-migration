# About
This module includes all the steps for creating GCS bucket to store the scripts and input data files for the usecase <br>

[1. Declare variables](02-bucket-creation-files-upload-cloud-shell.md#1-declare-variables) <br>
[2. GCS Bucket creation](02-bucket-creation-files-upload-cloud-shell.md#2-gcs-bucket-creation) <br>
[3. Uploading the repository files to GCS Bucket](02-bucket-creation-files-upload-cloud-shell.md#3-uploading-the-repository-files-to-gcs-bucket) <br>

## 0. Prerequisites
Please note down both gcp associated Project IDs. Assume one as an on-premises environment and other as google cloud environment, as we are going to address them accordingly throughout the lab.

#### 1. Create a new project or select an existing project.
Note down the on-premises project number and project ID.

#### 2. Activate Cloud Shell.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com/?show=ide%2Cterminal) <br>

Run the below command to set the project to cloud shell terminal:
```
gcloud config set project $ON_PREM_PROJECT_ID
```

## 1. Declare variables
We will use these throughout the lab. 
```
# Not required if you have declared all variables from '01-gcp-prerequisites-cloud-shell'

REGION=<region_where_resources_will_be_created>
ON_PREM_PROJECT_ID=$(gcloud config get-value project)
ON_PREM_PROJECT_NUM=$(gcloud projects list --filter="$ON_PREM_PROJECT_ID" --format="value(PROJECT_NUMBER)")
ON_PREM_STORAGE_BUCKET=<your_on_prem_storage_bucket_name>
ON_PREM_STAGING_BUCKET=<your_on_prem_staging_bucket_name>
```

## 2. GCS Bucket creation
Run the following gsutil command in Cloud Shell to create the bucket to store datasets and scripts.
```
gsutil mb -p $ON_PREM_PROJECT_ID -c STANDARD -l $REGION gs://$ON_PREM_STORAGE_BUCKET;
gsutil mb -p $ON_PREM_PROJECT_ID -c STANDARD -l $REGION gs://$ON_PREM_STAGING_BUCKET
```

## 3. Uploading the repository files to GCS Bucket
To copy the uploaded files from cloud shell instance to GCS, please follow the below steps:

- execute the follow commands in cloud shell, to upload the code and data files to GCS buckets from shell:

```
gsutil cp -r retail-data-lake-migration/* gs://$ON_PREM_STORAGE_BUCKET/retail-data-lake-migration/
```

**OR**

To upload the code repository, please follow the below steps:

* Extract the compressed code repository folder to your local Machine
* Next, navigate to the bucket created in previous step for storing the code and data files and upload the extracted code repository by
using the 'Upload Folder' option in Google Cloud Storage Bucket as shown below:

![this is a screenshot](/images/upload_to_gcs.png)