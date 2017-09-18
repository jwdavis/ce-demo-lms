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
    project_number = context.env['project_number']

    resources = []

    resources.append(
        {
            'name': context.properties['net_name'],
            'type': 'compute.v1.network',
            'properties': {
                'autoCreateSubnetworks': False
            }
        })

    for sub_num in range(0,len(context.properties['subnet_names'])):
        resources.append(
        {
            'name': '{}'.format(context.properties['subnet_names'][sub_num]),
            'type': 'compute.v1.subnetwork',
            'properties': {
                'network': '$(ref.{}.selfLink)'.format(context.properties['net_name']),
                'ipCidrRange': context.properties['subnet_ranges'][sub_num],
                'region': context.properties['subnet_regions'][sub_num]
            }
        })

    return {'resources': resources}
