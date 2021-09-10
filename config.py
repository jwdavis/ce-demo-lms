# Copyright 2017 SuccessOps, LLC All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import requests

def get_metadata(scope, key):
	if not os.environ.get('dev'):
		headers = {"Metadata-Flavor":"Google"}
		data = requests.get('http://metadata/computeMetadata/v1/{}/{}'.format(scope, key), headers=headers).content.decode()
		return data
	else:
		return os.environ.get(key)

PROJECT_ID = get_metadata("project", "project-id")
SERVER_ZONE = get_metadata("instance", "zone").split('/')[3]
SERVER_REGION = SERVER_ZONE[0:-2]
SERVER_NAME = get_metadata("instance", "hostname").split('.')[0]
SQL_USER = "root"
SQL_PASSWORD = get_metadata("instance", "attributes/SQL_PASS")
SQL_WRITE_INSTANCE = get_metadata("instance", "attributes/SQL_MAIN")
SQL_READ_INSTANCE = get_metadata("instance", "attributes/SQL_REPLICA")
CLOUD_STORAGE_BUCKET = "bdev2_raw_media_{}".format(PROJECT_ID)
SOURCE_STORAGE_BUCKET = "bdev2_raw_media_{}".format(PROJECT_ID)
TARGET_STORAGE_BUCKET = "bdev2_media_{}".format(PROJECT_ID)
