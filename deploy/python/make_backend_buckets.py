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
  resources = []

  for bucket in context.properties['buckets']:

    name = bucket['name']
    if bucket['suffix']:
      bucketName = '{}_{}'.format(bucket['bucketName'], project)
    else:
      bucketName = bucket['bucketName']
    enableCdn = bucket['enableCdn']

    resources.append(
      {
        'name': name,
        'type': 'compute.beta.backendBucket',
        'properties': {
          'bucketName': bucketName,
          'enableCdn': enableCdn
        }
      })

  return {'resources': resources}
