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

  for mig in context.properties['migs']:
    resource = {
      'name': mig['name'],
      'type': 'compute.v1.instanceGroupManager',
      'properties': {
          'baseInstanceName': mig['base'],
          'instanceTemplate': mig['template'],
          'targetSize': mig['size'],
          'zone': mig['zone']
      }
    }
    resources.append(resource)
    mig_ref = '$(ref.{}.selfLink)'.format(mig['name'])

    if mig['autoscaler']:
      autoscaler = mig['autoscaler']
      mig_autoscaler = {
        'name': '{}-autoscaler'.format(mig['name']),
        'type': 'compute.v1.autoscaler',
        'properties': {
          'zone': mig['zone'],
          'target': mig_ref
        }
      }
      if autoscaler['criteria'] == 'load_balancer':
        mig_autoscaler['properties']['autoscalingPolicy'] = {
          'minNumReplicas': autoscaler['min'],
          'maxNumReplicas': autoscaler['max'],
          'coolDownPeriodSec': autoscaler['cool'],
          'loadBalancingUtilization': {
            'utilizationTarget': autoscaler['util']
          }
        }
      else:
        mig_autoscaler['properties']['autoscalingPolicy'] = {
          'minNumReplicas': autoscaler['min'],
          'maxNumReplicas': autoscaler['max'],
          'coolDownPeriodSec': autoscaler['cool'],
          'cpuUtilization': {
            'utilizationTarget': autoscaler['util']
          }
        }

      resources.append(mig_autoscaler)

  return {'resources': resources}
