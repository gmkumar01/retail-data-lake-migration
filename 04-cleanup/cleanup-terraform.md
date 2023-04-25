# About

This module includes the steps for deleting the GCP resources created using Terraform for the usecase using Terraform modules<br>

1. Disable Google Dataproc, Cloud SQL Admin and Cloud Storage APIs<br>
2. Delete GCS buckets<br>
3. Delete SQL Instance<br>
4. Delete Dataproc Cluster on GCE<br>
5. Delete VPC Network<br>

## 0. Prerequisites

#### 1. Attach cloud shell to your project.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com). <br>
Run the below command to set the project to cloud shell terminal:
```
gcloud config set project <your_on_prem_project_id>
```

#### 2. Navigate to Terraform Directory.

Navigate to the Terraform directory in Cloud Shell by running the following command:<br>
```
cd retail-data-lake-migration/00-scripts-and-config/terraform
```

#### 3. Terraform State Files.

Once in the Terraform directory, run the following command in cloud shell after ensuring you have the 'terraform.tfstate', 'main.tf', 'variables.tf' and 'versions.tf' files.

## 1. Running the Terraform Script to destroy all resources created by Terraform script

Run the following commands in cloud shell to execute the terraform script in destroy mode: <br>

```
# Declare Variables:
ON_PREM_PROJECT_ID=$(gcloud config get-value project)
ON_PREM_PROJECT_NUM=$(gcloud projects list --filter="$ON_PREM_PROJECT_ID" --format="value(PROJECT_NUMBER)")

# Destroy Resources:
terraform destroy \
  -var="project_id=${ON_PREM_PROJECT_ID}" \
  -var="project_nbr=${ON_PREM_PROJECT_NUM}" \
  -auto-approve
  -lock=false
```
**NOTE** Use this method only if the resources are created using terraform. And make sure that the resources are up and running before destroying them.

Once the terraform script completes execution successfully, all resources created for the usecase by the Terraform script will be deleted.