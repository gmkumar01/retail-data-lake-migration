# About
This module includes all the steps for creating Cloud SQL Instance for the usecase

[1. Declare variables](03-cloud-sql-instance-creation-cloud-shell.md#1-declare-variables)<br>
[2. Create SQL Instance](03-cloud-sql-instance-creation-cloud-shell.md#2-create-sql-instance)

## 0. Prerequisites
Please note down both gcp associated Project IDs. Assume one as an on-premises environment and other as google cloud environment, as we are going to address them accordingly throughout the lab.

#### 1. Create a new projects or select an existing project.
Note down the on-premises project number and project ID.

#### 2. Activate Cloud Shell.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com/?show=ide%2Cterminal) Run the below command to set the project in the cloud shell terminal:
```
gcloud config set project $ON_PREM_PROJECT_ID
```

## 1. Declare variables
We will use these throughout the lab. 
```
# Not required if you have declared all variables from '01-gcp-prerequisites-cloud-shell'

ZONE=<zone_where_resources_will_be_created>
ON_PREM_PROJECT_NUM=$(gcloud projects list --filter="$ON_PREM_PROJECT_ID" --format="value(PROJECT_NUMBER)")
ON_PREM_METASTORE=<your_on_prem_metastore_name>
```

## 2. Create SQL Instance

Create a sql instance through the google cloud shell
```
gcloud sql instances create $ON_PREM_METASTORE --database-version="MYSQL_5_7" --activation-policy=ALWAYS --zone $ZONE
```