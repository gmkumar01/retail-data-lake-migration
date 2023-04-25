# About

This module includes all prerequisites for creating the resources needed in retail data lake migration usecase using Terraform modules 

1. Enable Google Dataproc, Google Cloud SQL and Cloud Storage APIs
2. Network Configuration
3. Create a GCS buckets to store code and data files and hive warehouse data, and Dataproc cluster staging bucket.
4. Create a SQL Instance
5. Create a Dataproc Cluster on GCE
6. [APIs and Roles required for the Hackfest Attendees](gcp-prerequisites-terraform.md#3-apis-and-roles-required-for-the-hackfest-attendees)<br>

## 0. Prerequisites
Please note down both gcp associated Project IDs. Assume one as an on-premises environment and other as google cloud environment, as we are going to address them accordingly throughout the lab.

#### 1. Create a new project or select an existing projects.
Note down the on-premises project number and project ID.

#### 2. IAM Roles needed to execute the prereqs
Ensure that you have **Security Admin**, **Project IAM Admin**, **Service Account Admin** and **Role Administrator** roles and then grant yourself the following additional roles in both the projects:<br>

```
Compute Network Admin
Cloud SQL Admin
Dataproc Editor
Dataproc Metastore Editor
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

## 2. Running the Terraform Script

#### 1. Customizing the terraform script

From the '00-scripts-and-config/terraform' folder, edit the 'main.tf' script by updating the values for the following variables:<br>

```
location                    = <region_where_resources_will_be_created>
zone                        = <zone_where_resources_will_be_created>
on_prem_staging_bucket      = <your_on_prem_cluster_staging_bucket_name>
sql_instance                = <your_on_prem_metastore_name>
warehouse_bucket            = <your_on_prem_storage_bucket_name>
on_prem_cluster             = <your_on_prem_cluster_name>
vpc_nm                      = <your_vpc_name>
subnet_nm                   = <your_subnet_name>
subnet_cidr                 = <your_subnet_cidr> #Example: "10.0.0.0/16"
firewall_nm                 = <your_firewall_name>
```

Once these values have been entered, please save the file.

#### 2. Uploading Terraform scripts, PySpark scripts and datasets to cloud shell

* Upload all the contents of repository to the Google Cloud Shell by using upload option in shell:

Run the following commands in Cloud Shell:
```
mkdir retail-data-lake-migration
cd retail-data-lake-migration
```

![Upload to shell.](/images/upload_to_shell1.png)
![Upload to shell.](/images/upload_to_shell2.png)

select the destination directory as "retail-data-lake-migration" after choosing files and click upload.

#### 3. Terraform Script Execution
Run following commands in cloud shell to execute the script:
```
# Navigate to the script:
cd retail-data-lake-migration/00-scripts-and-config/terraform/

# Declare Variables:
ON_PREM_PROJECT_ID=$(gcloud config get-value project)
ON_PREM_PROJECT_NUM=$(gcloud projects list --filter="$ON_PREM_PROJECT_ID" --format="value(PROJECT_NUMBER)")

# Execute the script:
terraform init
terraform apply \
  -var="project_id=${ON_PREM_PROJECT_ID}" \
  -var="project_nbr=${ON_PREM_PROJECT_NUM}" \
  -auto-approve
```

**NOTE:** If the script fails for the first execution, please re-run it.<br>

Once the terraform script completes execution successfully, the necessary resources for the usecase will be available to use.<br>

## 3. APIs and Roles required for the Hackfest Attendees

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