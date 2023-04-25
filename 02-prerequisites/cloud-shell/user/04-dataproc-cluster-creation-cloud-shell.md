# About

This module includes all prerequisites for setting up the Dataproc Cluster on GCE:<br>
[1. Declare variables](04-dataproc-cluster-creation-cloud-shell.md#1-declare-variables)<br>
[2. Create a Dataproc GCE Cluster](04-dataproc-cluster-creation-cloud-shell.md#2-create-a-dataproc-gce-cluster)

## 0. Prerequisites
Please note down both gcp associated Project IDs. Assume one as an on-premises environment and other as google cloud environment, as we are going to address them accordingly throughout the lab.

#### 1. GCP Project Details
Note down the gcloud project number and project ID.

#### 2. Activate Cloud Shell.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com) <br>
Run the below command to set the project to cloud shell terminal:
```
gcloud config set project $GOOG_PROJECT_ID
```

## 1. Declare variables
We will use these throughout the lab.
Run the below in cloud shell against the project you selected: <br>
```
# Not required if you have declared all variables from '01-network-creation-cloud-shell'

REGION=<region_where_resources_will_be_created>
SUBNET=$USER-<your_subnet_name>
GOOG_PROJECT_ID=$(gcloud config get-value project)
GOOG_CLUSTER=$USER-<your_gcloud_cluster_name>
GOOG_METASTORE=$USER-<your_gcloud_metastore_service_name>
GOOG_STAGING_BUCKET=$USER-<your_gcloud_staging_bucket_name>
```

## 2. Create a Dataproc GCE Cluster

#### Creating a default dataproc cluster which has 1 master and 2 worker nodes on on-prem project.
```
gcloud dataproc clusters create $GOOG_CLUSTER \
    --bucket $GOOG_STAGING_BUCKET \
    --region $REGION \
    --subnet $SUBNET \
    --dataproc-metastore projects/$GOOG_PROJECT_ID/locations/$REGION/services/$GOOG_METASTORE \
    --initialization-actions gs://goog-dataproc-initialization-actions-$REGION/oozie/oozie.sh \
    --metadata "enable-oozie-on-workers=false"
```