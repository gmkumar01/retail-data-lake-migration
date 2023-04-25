# About

This module includes all prerequisites for setting up the Dataproc Cluster on GCE:<br>
[1. Declare variables](04-dataproc-cluster-creation-cloud-shell.md#1-declare-variables)<br>
[2. Create a Dataproc Cluster on GCE](04-dataproc-cluster-creation-cloud-shell.md#2-create-a-dataproc-cluster-on-gce)

## 0. Prerequisites
Please note down both gcp associated Project IDs. Assume one as an on-premises environment and other as google cloud environment, as we are going to address them accordingly throughout the lab.

#### 1. GCP Project Details
Note down the on-premises project number and project ID.

#### 2. Activate Cloud Shell.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com/?show=ide%2Cterminal) <br>
Run the below command to set the project to cloud shell terminal:
```
gcloud config set project $ON_PREM_PROJECT_ID
```

## 1. Declare variables
We will use these throughout the lab.
Run the below in cloud shell against the project you selected: <br>

```
# Not required if you have declared all variables from '01-gcp-prerequisites-cloud-shell'

REGION=<region_where_resources_will_be_created>
ZONE=<zone_where_resources_will_be_created>
SUBNET=<your_subnet_name>
ON_PREM_PROJECT_ID=$(gcloud config get-value project)
ON_PREM_PROJECT_NUM=$(gcloud projects list --filter="$ON_PREM_PROJECT_ID" --format="value(PROJECT_NUMBER)")
ON_PREM_STORAGE_BUCKET=<your_on_prem_storage_bucket_name>
ON_PREM_STAGING_BUCKET=<your_on_prem_staging_bucket_name>
ON_PREM_CLUSTER=<your_on_prem_cluster_name>
ON_PREM_METASTORE=<your_on_prem_metastore_name>
```

## 2. Create a Dataproc Cluster on GCE

#### Creating a default dataproc cluster which has 1 master and 2 worker nodes on on-prem project.
```
gcloud dataproc clusters create $ON_PREM_CLUSTER \
    --bucket $ON_PREM_STAGING_BUCKET \
    --region $REGION \
    --zone $ZONE \
    --subnet $SUBNET \
    --scopes sql-admin \
    --initialization-actions gs://goog-dataproc-initialization-actions-$REGION/cloud-sql-proxy/cloud-sql-proxy.sh \
    --properties "hive:hive.metastore.warehouse.dir=gs://$ON_PREM_STORAGE_BUCKET/dlm-poc/hive-data" \
    --metadata "hive-metastore-instance=$ON_PREM_PROJECT_ID:$REGION:$ON_PREM_METASTORE" \
    --metadata "enable-cloud-sql-proxy-on-workers=false"
```