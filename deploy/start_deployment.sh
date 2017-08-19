 #!/bin/bash

sed -i -e "s/<sql-pass>/$1/g" deploy-gce-demo.yaml
sed -i -e "s/<sup-pass>/$2/g" deploy-gce-demo.yaml

gcloud deployment-manager deployments create test --config deploy-gce-demo.yaml

. ./finish_deployment.sh $1
