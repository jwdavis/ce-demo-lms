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

	for prefix in context.properties['prefixes']:
		resources.append(
			{
				'name': '{}_{}'.format(prefix,project),
				'type':	'storage.v1.bucket',
				'properties': {
					'storageClass':		context.properties['storageClass'],
					'location':			context.properties['location'],
					'defaultObjectAcl':	[
						{'entity': 'allUsers', 'role': 'READER'},
						{'entity': 'project-owners-{}'.format(project_number), 'role': 'OWNER'}
					]

				}
			})

	return {'resources': resources}
