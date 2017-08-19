 #!/bin/bash

PROJECT_ID=$(curl http://metadata.google.internal/computeMetadata/v1/project/project-id -H "Metadata-Flavor: Google")

# install necessary utilities
apt-get install -y \
python \
python-pip \
python-virtualenv \
python-dev \
supervisor \
libav-tools

# setup virtual environment for app
mkdir /venvs
virtualenv /venvs/transcode
source /venvs/transcode/bin/activate
pip install --upgrade pip
pip install \
Flask==0.12 \
google-cloud==0.23.0 \
requests

# config supervisor
sed -i -e "s/<supervisor_pass>/$1/g" /ce-demo-lms/admin/supervisor_config/supervisord.conf
cp /ce-demo-lms/admin/supervisor_config/supervisord.conf /etc/supervisor/.
cp /ce-demo-lms/admin/supervisor_config/transcode.conf /etc/supervisor/conf.d/.
supervisorctl reread
supervisorctl update
