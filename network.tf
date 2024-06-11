locals {
  cidr_block = "172.31.0.0/16"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_vpc" "main" {
  cidr_block       = local.cidr_block 

  tags = {
    Name        = "chaos_eng_vpc"
    Environment = "Chaos"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.cidr_block 
  map_public_ip_on_launch = true

  tags = {
    Name        = "chaos_eng_subnet"
    Environment = "Chaos"
  }
}

resource "aws_security_group" "ssh_ingress" {
  name   = "chaos_eng_ssh_ingress"
  vpc_id = aws_vpc.main.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ var.allowlist_ip, "${chomp(data.http.myip.response_body)}/32" ]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ local.cidr_block ]
  }

  tags = {
    Name        = "chaos_ssh_ingress_rule"
    Environment = "Chaos"
  }
}

resource "aws_security_group" "allow_outbound_http_https" {
  name        = "allow-outbound-http-https"
  description = "Security group to allow outbound HTTP and HTTPS"
  vpc_id      = aws_vpc.main.id

  # Step 2: Allow Outbound HTTP and HTTPS Traffic
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound HTTP traffic"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound HTTPS traffic"
  }

  tags = {
    Name = "allow-outbound-http-https"
  }
}

resource "aws_security_group" "allow_all_keyserver" {
  name        = "allow-all-keyserver"
  description = "Security group for accessing keyserver.ubuntu.com"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 11371
    to_port     = 11371
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HKP traffic"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

resource "aws_internet_gateway" "main" { 
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
 vpc_id = aws_vpc.main.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.main.id
 }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "tls_private_key" "keypair_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keypair" {
  key_name   = var.key_name

  public_key = tls_private_key.keypair_private_key.public_key_openssh

  # Create "id_rsa.pem" in local directory
  provisioner "local-exec" {
    command = "rm -rf id_rsa.pem && echo '${tls_private_key.keypair_private_key.private_key_pem}' > id_rsa.pem && chmod 400 id_rsa.pem"
  }

  tags = {
    Name        = "chaos_tls_private_key"
    Environment = "Chaos"
  }
}
