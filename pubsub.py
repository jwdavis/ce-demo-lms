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

from google.cloud import pubsub

# publish message to topic
def publish(topic, message, uri):
	client = pubsub.Client()
	topic = client.topic(topic)
	return topic.publish(message,uri=uri)

# stuff queue
def stuff_queue(topic):
	client = pubsub.Client()
	topic = client.topic(topic)
	return topic.publish(b'stuffing queue', uri='q_stuffing')
