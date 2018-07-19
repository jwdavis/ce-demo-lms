 #!/bin/bash

# update files to use command-line provided args
sed -i -e "s/<sql-pass>/$1/g" deploy.yaml
sed -i -e "s/<sup-pass>/$2/g" deploy.yaml
sed -i -e "s/<sql_name>/$4/g" deploy.yaml
sed -i -e "s/<billing>/$3/g" deploy.yaml
sed -i -e "s/<sql_name>/$4/g" finish_deployment.sh

# enable apis
gcloud services enable compute.googleapis.com
gcloud services enable deploymentmanager.googleapis.com
gcloud services enable sql-component.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable pubsub.googleapis.com

# create the deployment
gcloud deployment-manager deployments create lms --config deploy.yaml

# finish up with post-deployment actions
. ./finish_deployment.sh $1
