# Migrating On-Premises Hadoop Infrastructure to Google Cloud Using Cloud Services

## Overview
This Repository contains the instructions on migrating a retail on-premises hadoop infrastructure to Google Cloud. In this lab we use two Google Cloud Platform projects assuming one as on-premises infrastructure and other as gcloud environment, and migrate data from one environment to other using Google Cloud services.

## Prerequisites
To complete this lab, you will need the following:

* Access to a standard internet browser (Chrome browser recommended) and a good Internet connection.
* A Google account with access to Google Cloud Platform and two associated projects.
* Dataproc, Dataproc Metastore, Cloud SQL and Cloud Storage APIs Enabled along with the necessary roles to create, read or write object form and to Google Cloud Storage.
* A VPC network.
* Time to complete the exercise.

## Services Used
The services used in this lab are:
* Google Cloud Dataproc
* Google Cloud Dataproc Metastore
* Google Cloud SQL
* Google Cloud Storage

## Permissions / IAM Roles required to run the lab
Following are the required permissions / roles:

* Cloud SQL Admin
* Dataproc Editor
* Dataproc Metastore Editor
* Environment User and Storage Object Viewer
* IAP-secured Tunnel User
* Service Account User
* Storage Admin
* Viewer

## Checklist
Note down the following values before getting started with the lab:

* Cloud SQL instance name
* Dataproc cluster names
* Dataproc Metastore name
* GCP region and zone where all resources are created
* GCS bucket name to store code and data files
* Project IDs for both projects
* Subnet name
* VPC name

## Lab Modules

Please note down the project ids of both GCP associated projects. Assume one as an on-premises environment and other as google cloud environment, as we are going to address them accordingly throughout the lab.

The lab consists of the following modules.

1. Setting up the Environment (Admin Step)
    * There are 2 ways of setting up the prerequisites:
        * Using [Terraform Scripts](/02-prerequisites/terraform/gcp-prerequisites-terraform.md)
        * Using 'Gcloud commands'
            * [Setting up a VPC network and Permissions](/02-prerequisites/cloud-shell/admin/01-gcp-prerequisites-cloud-shell.md)
            * [Creating GCS buckets](/02-prerequisites/cloud-shell/admin/02-bucket-creation-files-upload-cloud-shell.md)
            * [Creating a SQL Instance](/02-prerequisites/cloud-shell/admin/03-cloud-sql-instance-creation-cloud-shell.md)
            * [Creating a Dataproc cluster](/02-prerequisites/cloud-shell/admin/04-dataproc-cluster-creation-cloud-shell.md)
            * [Creating required Tables](/02-prerequisites/cloud-shell/admin/05-tables-creation-and-export-metadata-cloud-shell.md)

2. Setting up the Environment (User Step)
    * There are 2 ways of setting up the prerequisites:
        * Using [Terraform Scripts](/02-prerequisites/terraform/terraform-user.md)
        * Using 'Gcloud commands'
            * [Setting up a VPC network](/02-prerequisites/cloud-shell/user/01-network-creation-cloud-shell.md)
            * [Creating GCS buckets](/02-prerequisites/cloud-shell/user/02-bucket-creation-cloud-shell.md)
            * [Creating a Dataproc Metastore](/02-prerequisites/cloud-shell/user/03-dataproc-metastore-creation-cloud-shell.md)
            * [Creating a Dataproc cluster](/02-prerequisites/cloud-shell/user/04-dataproc-cluster-creation-cloud-shell.md)

3. Migrating the data (Lab Execution Step)
    * Lab Execution using :
        * Using [Dataproc GCE cluster through Cloud shell](/03-execution-instructions/gcloud-execution.md)

4. Cleaning up the Environment (User Step)
   * Depending on whether the environment was setup using Terraform or gcloud commands, the GCP resources can be cleaned up in 2 ways:
        * Using [Terraform Scripts](/04-cleanup/cleanup-terraform-user.md)
        * Using [Gcloud commands](/04-cleanup/cleanup-user-cloud-shell.md)

        "Please make sure to clean up the environment after completion of the lab."

5. Cleaning up the Environment (Admin Step)
   * Depending on whether the environment was setup using Terraform or gcloud commands, the GCP resources can be cleaned up in 2 ways:
        * Using [Terraform Scripts](/04-cleanup/cleanup-terraform.md)
        * Using [Gcloud commands](/04-cleanup/cleanup-admin-cloud-shell.md)

        "Please make sure to clean up the environment after completion of the lab."