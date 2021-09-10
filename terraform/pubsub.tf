# create a set of topics
# takes a list of config objects as input
# handles minimal settings; can be expanded
resource "google_pubsub_topic" "topics" {
  count = length(var.topics)
  name  = var.topics[count.index]["name"]
}

# create a set of subscriptions
# takes a list of config objects as input
# looks up the topic id based on provided topic name
# handles minimal settings; can be expanded
resource "google_pubsub_subscription" "subscriptions" {
  count                = length(var.subscriptions)
  name                 = var.subscriptions[count.index]["name"]
  topic                = local.topics_ids[var.subscriptions[count.index]["topic"]]
  ack_deadline_seconds = var.subscriptions[count.index]["ack_deadline_seconds"]
}
