# About

This module includes all prerequisites for running the datalake migration usecase using Google Cloud Shell.

[1. Declare variables](01-network-creation-cloud-shell.md#1-declare-variables) <br>
[2. Network Configuration](01-network-creation-cloud-shell.md#2-network-configuration)<br>

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

This is needed for creating the GCP resources and granting access to attendees.

## 1. Declare variables 

We will use these throughout the lab. <br>
Run the below in cloud shell against the project you selected

```
GOOG_PROJECT_ID=$(gcloud config get-value project)
REGION=<region_where_resources_will_be_created>
ZONE=<zone_where_resources_will_be_created>
VPC=$USER-<your_vpc_name>
SUBNET=$USER-<your_subnet_name>
SUBNET_CIDR=<your_subnet_cidr> #Example: "10.0.0.0/16"
FIREWALL=$USER-<your_firewall_name>
GOOG_CLUSTER=$USER-<your_gcloud_cluster_name>
GOOG_METASTORE=$USER-<your_gcloud_metastore_service_name>
GOOG_STAGING_BUCKET=$USER-<your_gcloud_staging_bucket_name>
GOOG_STORAGE_BUCKET=$USER-<your_gcloud_storage_bucket_name>
GOOG_METASTORE_BUCKET=$USER-<your_gcloud_metastore_bucket_name>
```

**NOTE:** Please Use the values given by the admin.

## 2. Network Configuration

Run the commands below to create the networking entities required for the hands on lab.

#### 2.1. Create a VPC

```
gcloud compute networks create $VPC \
    --subnet-mode=custom \
    --bgp-routing-mode=regional \
    --mtu=1500
```

List VPCs with:

```
gcloud compute networks list
```

Describe your network with:

```
gcloud compute networks describe $VPC
```

#### 2.2. Create a subnet in the newly created VPC with private google access

```
gcloud compute networks subnets create $SUBNET \
     --network=$VPC \
     --range=$SUBNET_CIDR \
     --region=$REGION \
     --enable-private-ip-google-access
```

#### 2.3. Create firewall rules
Intra-VPC, allow all communication

```
gcloud compute firewall-rules create $FIREWALL \
    --project=$GOOG_PROJECT_ID  \
    --network=projects/$GOOG_PROJECT_ID/global/networks/$VPC \
    --description="Allows connection from any source to any instance on the network using custom protocols." \
    --direction=INGRESS \
    --priority=65534 \
    --source-ranges=$SUBNET_CIDR \
    --action=ALLOW --rules=all
```
