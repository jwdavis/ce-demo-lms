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