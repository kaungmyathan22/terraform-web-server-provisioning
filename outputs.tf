
output "ubuntu_latest_image_id" {
  value = data.aws_ami.ubuntu_latest_image_id.name
}

output "instance_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "instance_private_ip" {
  value = aws_instance.web_server.private_ip
}
