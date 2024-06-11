provider "aws" {
  region = var.region
}

resource "aws_instance" "ec2_instance" {
  ami                    = var.ami
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.main.id
  key_name               = aws_key_pair.keypair.key_name 
  vpc_security_group_ids = [aws_security_group.ssh_ingress.id, aws_security_group.allow_outbound_http_https.id, aws_security_group.allow_all_keyserver.id]
  user_data              = templatefile("${path.module}/userdata.tftpl", {
      gremlin_team_id     = var.gremlin_team_id
      gremlin_team_secret = var.gremlin_team_secret
  })

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name        = "chaos_tls_ec2_instance"
    Environment = "Chaos"
  }
}
