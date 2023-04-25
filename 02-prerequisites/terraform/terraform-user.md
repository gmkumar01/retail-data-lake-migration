# About

This module includes all prerequisites for creating the resources needed in retail data lake migration usecase using Terraform modules 

1. [APIs and Roles required for the Hackfest Attendees](terraform-user.md#1-apis-and-roles-required-for-the-hackfest-attendees)
2. Network Configuration
3. Create a GCS bucket to store code and data files, and Dataproc cluster staging bucket<br>
4. Create a Dataproc Metastore<br>
5. Create a Dataproc Cluster on GCE<br>
6. [Running the Terraform Script](terraform-user.md#2-running-the-terraform-script)

## 0. Prerequisites
Please note down both gcp associated Project IDs. Assume one as an on-premises environment and other as google cloud environment, as we are going to address them accordingly throughout the lab.

#### 1. Create a new project or select an existing projects.
Note the gcloud project number and project ID.

#### 2. Attach cloud shell to your project.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com/?show=ide%2Cterminal).
```
gcloud config set project <enter your gcloud project id here>
```

## 1. APIs and Roles required for the Hackfest Attendees

Make sure the required APIs and GCP roles to all attendees are enabled on both project to execute the hands-on labs:<br>

APIs required for all attendees on on-premises project:
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

## 2. Running the Terraform Script

#### 1. Customizing the terraform script

From the '00-scripts-and-config/terraform-user' folder, edit the 'main.tf' script by updating the values for the following variables:<br>

```
location                    = <region_where_resources_will_be_created>
zone                        = <zone_where_resources_will_be_created>
vpc_nm                      = ${local.user_id}-<your_vpc_network_name>
subnet_nm                   = ${local.user_id}-<your_subnet_name>
subnet_cidr                 = <your_subnet_cidr> # Example: "10.0.0.0/16"
firewall_nm                 = ${local.user_id}-<your_firewall_name>
goog_dp_cluster             = ${local.user_id}-<your_cluster_name>
dp_metastore_nm             = ${local.user_id}-<your_metastore_service_name>
dp_metastore_bucket         = ${local.user_id}-<your_metastore_bucket_name>
goog_staging_bucket         = ${local.user_id}-<your_cluster_staging_bucket_name>
goog_storage_bucket         = ${local.user_id}-<your_storage_bucket_name>
warehouse_bucket            = <on_prem_storage_bucket_name>
on_prem_cluster             = <on_prem_cluster_name>
```

**NOTE:** Please enter the values given by the admin.

#### 2. Uploading Terraform scripts, PySpark scripts and datasets to cloud shell

* Upload all the contents from repository to the Google Cloud Shell as shown below:

Run the following commands in Cloud Shell:
```
mkdir retail-data-lake-migration
cd retail-data-lake-migration
```

![Upload to shell.](/images/upload_to_shell1.png)
![Upload to shell.](/images/upload_to_shell2.png)

select the destination directory as "retail-data-lake-migration" after choosing files and click upload.

#### 2. Terraform Script Execution
Run following commands in cloud shell to execute the script:
```
# Navigate to the script:
cd retail-data-lake-migration/00-scripts-and-config/terraform-user

# Declare Variables:
ON_PREM_PROJECT_ID=<your_on_prem_project_id>  # Please use value given by admin
ON_PREM_PROJECT_NUM=$(gcloud projects list --filter="$ON_PREM_PROJECT_ID" --format="value(PROJECT_NUMBER)")
GOOG_PROJECT_ID=$(gcloud config get-value project)

# Execute the script:
terraform init
terraform apply \
  -var="user_id=$USER" \
  -var="project_id=${GOOG_PROJECT_ID}" \
  -var="on_prem_project_id=${ON_PREM_PROJECT_ID}" \
  -var="on_prem_project_num=${ON_PREM_PROJECT_NUM}" \
  -auto-approve
```

Once the terraform script completes execution successfully, the necessary resources for the usecase will be available to use.