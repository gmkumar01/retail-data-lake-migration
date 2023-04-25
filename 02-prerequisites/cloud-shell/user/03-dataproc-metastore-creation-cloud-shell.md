# About

This module includes all prerequisites for setting up the Cloud Metastore.

[1. Declare Variables](03-dataproc-metastore-creation-cloud-shell.md#1-declare-variables)<br>
[2. Create a Metastore](03-dataproc-metastore-creation-cloud-shell.md#2-create-a-metastore)<br>
[3. Metastore logs](03-dataproc-metastore-creation-cloud-shell.md#3-metastore-logs)

## 0. Prerequisites
Please note down both gcp associated Project IDs. Assume one as an on-premises environment and other as google cloud environment, as we are going to address them accordingly throughout the lab.

#### 1. GCP Project Details
Note down the gcloud project number and project ID.

#### 2. Attach cloud shell to your project
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com) <br>

Run the below command to set the project in the cloud shell terminal:
```
gcloud config set project $GOOG_PROJECT_ID
```

## 1. Declare variables
We will use these throughout the lab.
Run the below in cloud shell
```
PORT=9083 # Change the port number as per the Requirement.
TIER=Developer # Change the tier as per the Requirement.

# Not required if you have declared all variables from '01-network-creation-cloud-shell'

REGION=<region_where_resources_will_be_created>
GOOG_METASTORE=$USER-<your_gcloud_metastore_service_name>
GOOG_METASTORE_BUCKET=$USER-<your_gcloud_metastore_bucket_name>
VPC=$USER-<your_vpc_name>
```

## 2. Create a metastore

2.1. Create a metastore through the google cloud shell
```
gcloud metastore services create $GOOG_METASTORE \
    --location=$REGION \
    --network=$VPC \
    --port=$PORT \
    --tier=$TIER \
    --hive-metastore-configs="hive.metastore.warehouse.dir"="gs://$GOOG_METASTORE_BUCKET/hive_warehouse"
```

2.2. Create a metastore through the GCP console
Navigate to the Dataproc Service in your GCP project and click on Metastore

![This is a alt text.](/images/meta.png)
![This is a alt text.](/images/meta01.png)
![This is a alt text.](/images/meta02.png)

Next, fill in the following values in the metastore creation window :

* **Service name**   - A unique identifier for your environment
* **Data location**     - The region where you want to create the metastore
* **Metastore Version**    - #default
* **Release channel** - #default
* **Port** - #default

* **Service tier** - #default

* **Network Configuration** - select the network and subnetwork with Private Google Access Enabled

* Next under **Endpoint protocol** select one of the below options: 
 
 **Thrift**
 
 **gRPC**

* Click on **ADD LABELS** to attach the labels.

* Next, click on **Create** to create the Metastore.

## 3. Metastore logs
To view the metastore logs, click the 'View Logs' button on the metastore page and the logs will be shown as below:

![This is a alt text.](/images/meta_logs01.png)
![This is a alt text.](/images/meta_logs02.png)