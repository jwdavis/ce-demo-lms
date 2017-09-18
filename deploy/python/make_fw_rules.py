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

  resources = []

  for rule in context.properties['rules']:

    allow_payload = []
    for allow in rule['allowed']:
      allow_payload.append({
        'IPProtocol': allow['IPProtocol'],
        'ports': allow['ports']
      })

    resource = {
      'name': rule['name'],
      'type': 'compute.v1.firewall',
      'properties': {
        'network': rule['network'],
        'sourceRanges': rule['source_ranges'],
        'allowed': rule['allowed'],
      }
    }

    if 'target_tags' in rule:
      resource['properties']['targetTags'] = rule['target_tags']

    resources.append(resource)

  return {'resources': resources}
