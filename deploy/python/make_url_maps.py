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

  for url_map in context.properties['url_maps']:
    name = url_map['name']

    # build list of host rules
    host_rules = []
    for rule in url_map['host_rules']:
      host_rule = {}
      host_rule['pathMatcher'] = rule['pm']
      hosts = []
      for host in rule['hosts']:
        hosts.append(host)
      host_rule['hosts'] = hosts
      host_rules.append(host_rule)

    # build path matchers
    path_matchers = []
    for matcher in url_map['path_matchers']:
      path_matcher = {}
      path_matcher['name'] = matcher['name']
      path_matcher['defaultService'] = '$(ref.{}.selfLink)'.format(matcher['default_service'])
      path_rules = []
      for rule in matcher['path_rules']:
        path_rule = {}
        path_rule['paths'] = rule['paths']
        path_rule['service'] = '$(ref.{}.selfLink)'.format(rule['service_name'])
        path_rules.append(path_rule)
      path_matcher['pathRules'] = path_rules
      path_matchers.append(path_matcher)

    resource = {
        'name': name,
        # 'description': path_matchers,
        'type': 'compute.v1.urlMap',
        'properties': {
          'defaultService': '$(ref.{}.selfLink)'.format(url_map['default_service']),
          'hostRules': host_rules,
          'pathMatchers': path_matchers
        }
      }
    resources.append(resource)

  return {'resources': resources}
