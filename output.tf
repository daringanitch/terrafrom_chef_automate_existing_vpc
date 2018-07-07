output "privatednschefserver" {
  value = "${aws_instance.chef-server.private_dns}"
}
output "privatednscautomateserver" {
  value = "${aws_instance.automate-server.private_dns}"
}
