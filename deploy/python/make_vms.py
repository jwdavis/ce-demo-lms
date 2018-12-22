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

  for vm in context.properties['vms']:
    resource = {
      'name': vm['name'],
      'type': 'compute.v1.instance',
      'properties': {
        'zone': vm['zone'],
        'machineType': '{}/zones/{}/machineTypes/{}'.format(base_url,vm['zone'],vm['machine-type']),
        'networkInterfaces': [{
            'network': vm['network'],
            'accessConfigs': [{
              'name': 'External NAT',
              'type': 'ONE_TO_ONE_NAT'}],
            'subnetwork': vm['subnet'],
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
              'value': vm['startup']
          }]
        },
      }
    }

    resources.append(resource)

  return {'resources': resources}
