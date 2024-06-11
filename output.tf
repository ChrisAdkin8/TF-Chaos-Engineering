output "ssh_command" {
  value = <<CONFIGURATION
ssh -i id_rsa.pem ubuntu@${(aws_instance.ec2_instance.public_ip)}
CONFIGURATION
}
