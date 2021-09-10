# create a set of GCS buckets
# take a list of configuration objects as input
# append the project name as a suffix to provided bucket names
# leave many bucket settings at default - can expand later on
resource "google_storage_bucket" "buckets" {
  count                       = length(var.buckets)
  force_destroy               = true
  name                        = format("%s_%s", var.buckets[count.index]["name"], var.project)
  location                    = var.buckets[count.index]["location"]
  storage_class               = var.buckets[count.index]["class"]
  uniform_bucket_level_access = var.buckets[count.index]["uniform"]
}

resource "time_sleep" "wait_for_buckets" {
  depends_on      = [google_storage_bucket.buckets]
  create_duration = "10s"
}

# create a set of bucket role bindings
# take a list of configuration objects as input
# append the project name as a suffix to provided bucket names
# leave many bucket settings at default - can expand later on
resource "google_storage_bucket_iam_member" "bucket_bindings" {
  count      = length(var.bucket_bindings)
  bucket     = format("%s_%s", var.bucket_bindings[count.index]["bucket"], var.project)
  role       = var.bucket_bindings[count.index]["role"]
  member     = var.bucket_bindings[count.index]["member"]
  depends_on = [time_sleep.wait_for_buckets]
}
