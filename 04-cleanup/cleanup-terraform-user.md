# About

This module includes the steps for deleting the GCP resources created using Terraform for the usecase using Terraform modules<br>

1. Disable Google Dataproc, Dataproc Metastore and Cloud Storage APIs<br>
2. Delete GCS buckets<br>
3. Delete Dataproc Metastore<br>
4. Delete Dataproc Cluster on GCE<br>
5. Delete VPC Network<br>

## 0. Prerequisites

#### 1. Attach cloud shell to your project.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com). <br>
Run the below command to set the project to cloud shell terminal:
```
gcloud config set project <your_gcloud_project_id>
```

#### 2. Navigate to Terraform Directory.

Navigate to the Terraform directory in Cloud Shell by running the following command:<br>
```
cd retail-data-lake-migration/00-scripts-and-config/terraform-user/
```

#### 3. Terraform State Files.

Once in the Terraform directory, run the following command in cloud shell after ensuring you have the 'terraform.tfstate', 'main.tf', 'variables.tf' and 'versions.tf' files.

## 1. Running the Terraform Script to destroy all resources created by Terraform script

Run the following commands in cloud shell to execute the terraform script in destroy mode: <br>

```
# Declare Variables:
ON_PREM_PROJECT_ID=<your_on_prem_project_id>  # Please use value given by admin
ON_PREM_PROJECT_NUM=$(gcloud projects list --filter="$ON_PREM_PROJECT_ID" --format="value(PROJECT_NUMBER)")
GOOG_PROJECT_ID=$(gcloud config get-value project)

# Destroying Resources:
terraform destroy \
  -var="user_id=$USER" \
  -var="project_id=${GOOG_PROJECT_ID}" \
  -var="on_prem_project_id=${ON_PREM_PROJECT_ID}" \
  -var="on_prem_project_num=${ON_PREM_PROJECT_NUM}" \
  -auto-approve
  -lock=false
```
**NOTE** Use this method only if the resources are created using terraform.

Once the terraform script completes execution successfully, all resources created for the usecase by the Terraform script will be deleted.