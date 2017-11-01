 #!/bin/bash

# update file to use provided passwords
sed -i -e "s/<sql-pass>/$1/g" deploy-gce-demo.yaml
sed -i -e "s/<sup-pass>/$2/g" deploy-gce-demo.yaml

# do sqladmin outside deployment manager due to timing delays
# that sometime cause deployments to fail
gcloud service-management enable sqladmin.googleapis.com

# do compute engine outside of deployment so you can delete
# deployment without disabling compute engine api
gcloud service-management enable compute.googleapis.com

# enable deployment manager api
gcloud service-management enable deploymentmanager.googleapis.com

# create the deployment
gcloud deployment-manager deployments create lms --config deploy-gce-demo.yaml

# finish up with post-deployment actions
. ./finish_deployment.sh $1
