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

def GenerateConfig(context):

	project = context.env['project']
	base_url = 'https://www.googleapis.com/compute/v1/projects/{}'.format(project)

	resources = []

	resource = {
      'name': 'test',
      'type': 'compute.v1.instance',
      'properties': {
        'zone': 'us-central1-a',
        'machineType': '{}/zones/us-central1-a/machineTypes/n1-standard-1'.format(base_url),
        'networkInterfaces': [{
            'accessConfigs': [{
              'name': 'External NAT',
              'type': 'ONE_TO_ONE_NAT'}]
        }],
        'disks': [{
          'deviceName': 'boot',
          'type': 'PERSISTENT',
          'boot': True,
          'autoDelete': True,
          'initializeParams': {
              'sourceImage': 'https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/family/debian-8'
            }
        }],
		'serviceAccounts': [{
		  'email': 'default',
	        'scopes': [
	              'https://www.googleapis.com/auth/compute.readonly',
	              'https://www.googleapis.com/auth/cloud.useraccounts.readonly',
	              'https://www.googleapis.com/auth/devstorage.read_write',
	              'https://www.googleapis.com/auth/logging.write',
	              'https://www.googleapis.com/auth/monitoring.write',
	              'https://www.googleapis.com/auth/service.management.readonly',
	              'https://www.googleapis.com/auth/servicecontrol',
	              'https://www.googleapis.com/auth/pubsub',
	              'https://www.googleapis.com/auth/sqlservice.admin'
	        ]
	    }]
      }
    }

	resources.append(resource)

	return {'resources': resources}