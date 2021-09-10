#!/bin/bash
if [ ! -f /initialized.txt ]; then
  SUP_PASS=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/SUP_PASS -H "Metadata-Flavor: Google")
  SQL_PASS=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/SQL_PASS -H "Metadata-Flavor: Google")
  SQL_WRITE_INSTANCE=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/SQL_MAIN -H "Metadata-Flavor: Google")
  SQL_READ_INSTANCE=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/SQL_REPLICA -H "Metadata-Flavor: Google")
  SQL_WRITE_REGION=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/SQL_WRITE_REGION -H "Metadata-Flavor: Google")
  SQL_READ_REGION=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/SQL_READ_REGION -H "Metadata-Flavor: Google")
  PROJECT_ID=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/PROJECT_ID -H "Metadata-Flavor: Google")
  
  sed -i -e "s/<supervisor_pass>/$SUP_PASS/g" /ce-demo-lms/admin/supervisor_config/supervisord.conf
  sed -i -e "s/<project-id>/$PROJECT_ID/g" /ce-demo-lms/admin/supervisor_config/proxy.conf
  sed -i -e "s/<sql_name>/$SQL_WRITE_INSTANCE/g" /ce-demo-lms/admin/supervisor_config/proxy.conf
  sed -i -e "s/<region>/$SQL_WRITE_REGION/g" /ce-demo-lms/admin/supervisor_config/proxy.conf
  sed -i -e "s/<project-id>/$PROJECT_ID/g" /ce-demo-lms/admin/supervisor_config/read_proxy.conf
  sed -i -e "s/<sql_name>/$SQL_READ_INSTANCE/g" /ce-demo-lms/admin/supervisor_config/read_proxy.conf
  sed -i -e "s/<region>/$SQL_READ_REGION/g" /ce-demo-lms/admin/supervisor_config/read_proxy.conf
  cp /ce-demo-lms/admin/supervisor_config/supervisord.conf /etc/supervisor/.
  cp /ce-demo-lms/admin/supervisor_config/lms.conf /etc/supervisor/conf.d/.
  cp /ce-demo-lms/admin/supervisor_config/proxy.conf /etc/supervisor/conf.d/.
  cp /ce-demo-lms/admin/supervisor_config/read_proxy.conf /etc/supervisor/conf.d/.
  supervisorctl reread
  supervisorctl update

  cp /ce-demo-lms/admin/nginx_config/default /etc/nginx/sites-available/default
  ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
  service nginx reload
  touch /initialized.txt
fi