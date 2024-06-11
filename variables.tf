variable "region" {
  description = "The AWS region to deploy to"
  default     = "us-east-1"
}

variable "key_name" {
  description = "The name of the AWS SSH key to be loaded on the instance at provisioning."
  default     = "id_rsa.pub.chaos"
}

variable "allowlist_ip" {
  description = "IP to allow access for the security groups (set 0.0.0.0/0 for world)"
  default     = "172.31.32.0/20"
}

variable "ec2_instance_type" {
  description = "The AWS instance type to use for servers."
  default     = "t2.micro"
}

variable "ami" {
  description = "Id of the AMI to use when creating the EC2 instance"
  default     = "ami-0f2a1bb3c242fe285"
}

variable "gremlin_team_id" {
  description = "Id of the Gremlin team for registering agent against"
}

variable "gremlin_team_secret" {
  description = "Secret of the Gremlin team for registering agent against"
}
