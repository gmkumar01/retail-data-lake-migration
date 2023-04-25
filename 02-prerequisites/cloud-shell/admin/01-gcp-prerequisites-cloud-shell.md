# About

This module includes all prerequisites for running the datalake migration usecase using Google Cloud Shell.

[1. Enable Google Dataproc, Cloud SQL Admin and Cloud Storage APIs](01-gcp-prerequisites-cloud-shell.md#1-enable-google-dataproc-cloud-sql-admin-and-cloud-storage-apis) <br>
[2. Declare variables](01-gcp-prerequisites-cloud-shell.md#2-declare-variables) <br>
[3. Network Configuration](01-gcp-prerequisites-cloud-shell.md#3-network-configuration)<br>
[4. Grant IAM permissions for Compute Engine Service Account](01-gcp-prerequisites-cloud-shell.md#4-grant-iam-permissions-for-compute-engine-service-account) <br>
[5. Upload files to Cloud Shell Instance](01-gcp-prerequisites-cloud-shell.md#5-upload-files-to-cloud-shell-instance) <br>
[6. APIs and Roles required for the Hackfest Attendees](01-gcp-prerequisites-cloud-shell.md#6-apis-and-roles-required-for-the-hackfest-attendees) <br>

## 0. Prerequisites 
Please note down both gcp associated Project IDs. Assume one as an on-premises environment and other as google cloud environment, as we are going to address them accordingly throughout the lab.

#### 1. Create a new project or select an existing project.
Note down the on-premises project number and project id.

#### 2. IAM Roles needed to execute the prereqs
Ensure that you have **Security Admin**, **Project IAM Admin**, **Service Account Admin** and **Role Administrator** roles and then grant yourself the following additional roles in both the projects:<br>

```
Compute Network Admin
Cloud SQL Admin
Dataproc Admin
Storage Admin
Service Account User
Viewer
```

This is needed for creating the GCP resources and granting access to attendees.

#### 3. Attach cloud shell to your project.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com). <br>
Run the below command to set the project to cloud shell terminal:
```
gcloud config set project <gcloud_project_id>
```

## 1. Enable APIs

Run the following commands in cloud shell to enable the APIs:<br>
```
gcloud services enable dataproc.googleapis.com
gcloud services enable metastore.googleapis.com
gcloud services enable storage.googleapis.com
```

Run below command to set the project to on-premises enviroment
```
gcloud config set project <on_premises_project_id>
```

Run the following commands in cloud shell to enable the APIs:<br>
```
gcloud services enable dataproc.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable storage.googleapis.com
```

## 2. Declare variables 

We will use these throughout the lab. <br>
Run the below in cloud shell against the project you selected

```
ON_PREM_PROJECT_ID=$(gcloud config get-value project)
ON_PREM_PROJECT_NUM=$(gcloud projects list --filter="$ON_PREM_PROJECT_ID" --format="value(PROJECT_NUMBER)")
REGION=<region_where_resources_will_be_created>
ZONE=<zone_where_resources_will_be_created>
VPC=<your_vpc_name>
SUBNET=<your_subnet_name>
SUBNET_CIDR=<your_subnet_cidr> #Example: "10.0.0.0/16"
FIREWALL=<your_firewall_name>
ON_PREM_STORAGE_BUCKET=<your_on_prem_storage_bucket_name>
ON_PREM_METASTORE=<your_on_prem_metastore_name>
ON_PREM_CLUSTER=<your_on_prem_cluster_name>
ON_PREM_STAGING_BUCKET=<your_on_prem_staging_bucket_name>
```

## 3. Network Configuration

Run the commands below to create the networking entities required for the hands on lab.

#### 3.1. Create a VPC

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

#### 3.2. Create a subnet in the newly created VPC with private google access

```
gcloud compute networks subnets create $SUBNET \
     --network=$VPC \
     --range=$SUBNET_CIDR \
     --region=$REGION \
     --enable-private-ip-google-access
```

#### 3.3. Create firewall rules
Intra-VPC, allow all communication

```
gcloud compute firewall-rules create $FIREWALL \
    --project=$ON_PREM_PROJECT_ID  \
    --network=projects/$ON_PREM_PROJECT_ID/global/networks/$VPC \
    --description="Allows connection from any source to any instance on the network using custom protocols." \
    --direction=INGRESS \
    --priority=65534 \
    --source-ranges=$SUBNET_CIDR \
    --action=ALLOW --rules=all
```

## 4. Grant IAM Permissions for Compute Engine Service Account

#### 4.1. Basic role for Compute Engine Service Account
```
gcloud projects add-iam-policy-binding $ON_PREM_PROJECT_ID \
    --member serviceAccount:$ON_PREM_PROJECT_NUM-compute@developer.gserviceaccount.com --role roles/editor
```

## 5. Upload files to Cloud Shell Instance

- Upload the folders from repository to the Google Cloud Shell as shown below:<br>

Run the following commands in Cloud Shell:<br>
```
mkdir retail-data-lake-migration
cd retail-data-lake-migration
```
![this is a screenshot](/images/upload_to_shell1.png)
![this is a screenshot](/images/upload_to_shell2.png)

select the destination directory as "retail-data-lake-migration" after choosing files and click upload.

## 6. APIs and Roles required for the Hackfest Attendees

Please enable the required apis and grant the following GCP roles to all attendees on both project to execute the hands-on labs:<br>

APIs to be enabled for all attendees on on-premises project:
```
Google Cloud Dataproc
Google Cloud Storage
```

APIs to be enabled for all attendees on google cloud project:
```
Google Cloud Dataproc
Google Cloud Dataproc Metastore
Google Cloud Storage
```

Roles Required for all the attendees on both projects:
```
Compute Network Admin
Dataproc Editor
Dataproc Metastore Editor
IAP Tunnel User
Service Account User
Storage Admin
Viewer
```