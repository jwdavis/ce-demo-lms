PROJECT_ID=$(curl http://metadata.google.internal/computeMetadata/v1/project/project-id -H "Metadata-Flavor: Google")
SQL_PASS=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/sql-pass -H "Metadata-Flavor: Google")
SUP_PASS=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/sup-pass -H "Metadata-Flavor: Google")
SQL_NAME=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/sql-name -H "Metadata-Flavor: Google")
echo $PROJECT_ID
echo $SQL_PASS
echo $SUP_PASS
echo $SQL_NAME

source /venvs/lms/bin/activate

if [ ! -f /initialized.txt ]; then
  #update config
  echo "sed config-sql-pass"
  sed -i -e "s/<sql_pass>/$SQL_PASS/g" /ce-demo-lms/config.py
  echo "sed config-sql-name"
  sed -i -e "s/<sql_name>/$SQL_NAME/g" /ce-demo-lms/config.py

  #config nginx
  echo "sed nginx admin"
  sed -i -e "s/<bucket>/bdev2_raw_media_$PROJECT_ID/g" /ce-demo-lms/admin/nginx_config/default
  cp /ce-demo-lms/admin/nginx_config/default /etc/nginx/sites-available/default
  ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
  service nginx reload

  #config supervisor
    echo "sed supervisor stuff"
  sed -i -e "s/<supervisor_pass>/$SUP_PASS/g" /ce-demo-lms/admin/supervisor_config/supervisord.conf
  sed -i -e "s/<project-id>/$PROJECT_ID/g" /ce-demo-lms/admin/supervisor_config/proxy.conf
  sed -i -e "s/<sql_name>/$SQL_NAME/g" /ce-demo-lms/admin/supervisor_config/proxy.conf

  #finish config
  cp /ce-demo-lms/admin/supervisor_config/supervisord.conf /etc/supervisor/.
  cp /ce-demo-lms/admin/supervisor_config/lms.conf /etc/supervisor/conf.d/.
  cp /ce-demo-lms/admin/supervisor_config/proxy.conf /etc/supervisor/conf.d/.
  supervisorctl reread
  supervisorctl update
  touch /initialized.txt
fi
