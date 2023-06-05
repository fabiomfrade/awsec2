####################
# Get Data Account #
####################

data "aws_ami" "amzn2" {
  owners      = ["amazon"]
  most_recent = true
  name_regex  = "amazon"

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_vpc" "MyVPC" {
  filter {
    name   = "tag:Name"
    values = ["Main VPC"]
  }
}

data "aws_subnet" "defaultSB" {
  filter {
    name   = "tag:Name"
    values = ["Corp_Net_A - Public"]
  }
}

data "aws_security_group" "sshSG" {
  filter {
    name   = "tag:name"
    values = ["ssh"]
  }
}

###################
#  Create Locals  #
###################

locals {
  tags_comuns = {
    Name    = var.ec2_name
    Key     = var.nome_chave
    Contact = var.contato
  }
}

###################
#  Create Web SG  #
###################

resource "aws_security_group" "web" {
  name        = "allow_web_access"
  description = "Allow HTTP and HTTPS Access"
  vpc_id      = data.aws_vpc.MyVPC.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "Allow_Web_Access"
    Managed = "Terraform"
  }
}

###################
#   Create EC2    #
###################

resource "aws_instance" "docker_ec2" {
  ami           = data.aws_ami.amzn2.id
  instance_type = var.tamanho_ec2
  key_name      = var.nome_chave
  subnet_id     = data.aws_subnet.defaultSB.id

  associate_public_ip_address = true
  security_groups             = [data.aws_security_group.sshSG.id, aws_security_group.web.id]

  ebs_optimized = true

  monitoring              = false
  disable_api_termination = true

  user_data = filebase64("${path.module}/files/instala_docker.sh")

  tags = local.tags_comuns
}
