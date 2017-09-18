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

	for sub in range(0,len(context.properties['sub-names'])):
		sub_name = context.properties['sub-names'][sub]
		topic_name = context.properties['topics'][sub]
		resources.append({
			'name':			sub_name,
			'type':			'pubsub.v1.subscription',
			'properties':	{
				'name': sub_name,
				'subscription': sub_name,
				'topic': '$(ref.{}.name)'.format(topic_name),
				'ackDeadlineSeconds': 30
			}
		})

	return {'resources': resources}
