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

	project_id = context.env['project']
	billing_account = context.properties['billing_account']

	resources = []

	for api in context.properties['apis']:
		resources.append(
			{
				'name': api,
				'type':	'deploymentmanager.v2.virtual.enableService',
				'properties': {
					'consumerId': 'project:{}'.format(project_id),
					'serviceName': api
				}
			})

	return {'resources': resources}