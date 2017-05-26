"""
Copyright SuccessOps, LLC 2017
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

from google.cloud import pubsub

# publish message to topic
def publish(topic,message,uri):
	client = pubsub.Client()
	topic = client.topic(topic)
	return topic.publish(message,uri=uri)

# stuff queue
def stuff_queue(topic):
	client = pubsub.Client()
	topic = client.topic(topic)
	return topic.publish(b'stuffing queue',uri='q_stuffing')