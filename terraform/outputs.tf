# output "test" {
#   value = local.all_sql_instances
# }

# output "test2" {
#   value = module.gce-lb-https.external_ip
# }

output "commands" {
  value = <<EOF
Here are the commands for the typical demo...

[Test 1] watch -n 1 curl -o /dev/null http://${module.gce-lb-https.external_ip}/
[Test 2] ab -n 2500 -c 1 -r -l http://${module.gce-lb-https.external_ip}/videos/mantas.mp4
[Test 3] ab -n 100000 -c 3 -r -l http://${module.gce-lb-https.external_ip}/
EOF
}
