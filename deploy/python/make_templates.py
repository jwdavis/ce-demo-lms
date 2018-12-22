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
#from google.cloud import logging

def GenerateConfig(context):

  project = context.env['project']
  project_number = context.env['project_number']
  base_url = 'https://www.googleapis.com/compute/v1/projects/{}'.format(project)

  resources = []

  for template in context.properties['templates']:
    resource = {
      'name': template['name'],
      'type': 'compute.v1.instanceTemplate',
      'properties': {
        # 'zone': template['zone'],
        'properties':{
          'machineType': template['machine-type'],
          'tags': {'items': template['tags']},
          'networkInterfaces': [{
              'network': template['network'],
              'accessConfigs': [{
                'name': 'External NAT',
                'type': 'ONE_TO_ONE_NAT'}],
              'subnetwork': template['subnet']
          }],
          'disks': [{
            'deviceName': 'boot',
            'type': 'PERSISTENT',
            'boot': True,
            'autoDelete': True,
            'initializeParams': {
                'sourceImage': 'https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/family/debian-9'
              }
          }],
          'metadata': {
            'items': [{
                'key': 'startup-script',
                'value': template['startup-script'].format(*template['script_args'])
            }]
          },
          'serviceAccounts': [{
            'email': 'default',
            'scopes': template['scopes']
          }]
        }
      }
    }

    resources.append(resource)

  return {'resources': resources}
