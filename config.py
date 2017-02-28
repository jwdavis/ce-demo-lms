import os
import requests

def get_metadata(scope,key):
	if not os.environ.get('dev'):
		print 'http://metadata/computeMetadata/v1/{}/{}'.format(scope,key)
		headers = {"Metadata-Flavor":"Google"}
		return requests.get('http://metadata/computeMetadata/v1/{}/{}'.format(scope,key), headers=headers).content
	else:
		return os.environ.get(key)

PROJECT_ID = get_metadata("project","project-id")
SERVER_ZONE = get_metadata("instance","zone").split('/')[3]
SERVER_NAME = get_metadata("instance","hostname").split('.')[0]

SQL_CONNECTION_NAME = "{}:us-central1:lms-sql=tcp:3306".format(PROJECT_ID)
SQL_USER = "root"
SQL_PASSWORD = "<sql_pass>"

CLOUD_STORAGE_BUCKET = "bdev2_raw_media_{}".format(PROJECT_ID)
