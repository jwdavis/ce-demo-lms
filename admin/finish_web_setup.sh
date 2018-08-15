 #!/bin/bash

PROJECT_ID=$(curl http://metadata.google.internal/computeMetadata/v1/project/project-id -H "Metadata-Flavor: Google")

# install necessary utilities
apt-get install -y \
python \
python-pip \
python-virtualenv \
nginx \
gunicorn \
python-dev \
default-libmysqlclient-dev \
python-mysqldb \
supervisor

# setup virtual environment for app
mkdir /venvs
virtualenv /venvs/lms
source /venvs/lms/bin/activate
pip install --upgrade pip
pip install \
Flask==0.12 \
gunicorn==19.6.0 \
mysql-python \
google-cloud==0.23.0 \
requests

# modify config.py
sed -i -e "s/<sql_pass>/$1/g" /ce-demo-lms/config.py
sed -i -e "s/<sql_name>/$3/g" /ce-demo-lms/config.py

# config nginx
sed -i -e "s/<bucket>/bdev2_raw_media_$PROJECT_ID/g" /ce-demo-lms/admin/nginx_config/default
cp /ce-demo-lms/admin/nginx_config/default /etc/nginx/sites-available/default
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
service nginx reload

# set up cloud sql proxy
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64; \
sudo mkdir /proxy; \
sudo mv cloud_sql_proxy.linux.amd64 /proxy/cloud_sql_proxy; \
sudo chmod +x /proxy/cloud_sql_proxy

# config supervisor
sed -i -e "s/<supervisor_pass>/$2/g" /ce-demo-lms/admin/supervisor_config/supervisord.conf
sed -i -e "s/<project-id>/$PROJECT_ID/g" /ce-demo-lms/admin/supervisor_config/proxy.conf
sed -i -e "s/<sql_name>/$3/g" /ce-demo-lms/admin/supervisor_config/proxy.conf

cp /ce-demo-lms/admin/supervisor_config/supervisord.conf /etc/supervisor/.
cp /ce-demo-lms/admin/supervisor_config/lms.conf /etc/supervisor/conf.d/.
cp /ce-demo-lms/admin/supervisor_config/proxy.conf /etc/supervisor/conf.d/.
supervisorctl reread
supervisorctl update
