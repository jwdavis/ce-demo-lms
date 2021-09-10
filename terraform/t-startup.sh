#!/bin/bash
if [ ! -f /initialized.txt ]; then
  SUP_PASS=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/sup-pass -H "Metadata-Flavor: Google")
  sed -i -e "s/<supervisor_pass>/$SUP_PASS/g" /ce-demo-lms/admin/supervisor_config/supervisord.conf
  cp /ce-demo-lms/admin/supervisor_config/supervisord.conf /etc/supervisor/.
  cp /ce-demo-lms/admin/supervisor_config/transcode.conf /etc/supervisor/conf.d/.
  supervisorctl reread
  supervisorctl update
  touch /initialized.txt
fi