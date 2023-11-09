data "aws_ami" "ubuntu_latest_image_id" {
  most_recent = true
  owners      = [var.ami_owner]
  filter {
    name   = "name"
    values = [var.ami_name]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = [var.ami_virtualization_type]
  }
}

resource "aws_vpc" "production" {
  cidr_block = var.vpc_cidr_block
  tags = {
    project = var.project_name
    Name    = "Production vpc for ${var.project_name}"
  }
}

resource "aws_internet_gateway" "igw_ztm" {
  vpc_id = aws_vpc.production.id
  tags = {
    project = var.project_name
    Name    = "Internet getway for ${var.project_name}"
  }
}


resource "aws_subnet" "webapps" {
  availability_zone = var.subnet_az
  cidr_block        = var.subnet_cidr_block
  vpc_id            = aws_vpc.production.id
  tags = {
    Name    = "Web application subnets for ${var.project_name}"
    project = var.project_name
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.production.default_route_table_id
}

resource "aws_route" "default_to_igw" {
  route_table_id         = aws_default_route_table.default.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_ztm.id
}

# resource "aws_route_table_association" "association_subnet" {
#   subnet_id      = aws_subnet.webapps.id
#   route_table_id = aws_route_table.rtb_ztm.id
# }

# resource "aws_route_table" "rtb_ztm" {
#   vpc_id = aws_vpc.production.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw_ztm.id
#   }
#   tags = {
#     project = var.project_name
#     Name    = "Route table for ${var.project_name}"
#   }

# }

resource "aws_security_group" "instance_firewall" {
  name        = "firewall_config_for_${var.project_name}"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.production.id

  ingress {
    description = "allow ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "non http access"
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
    Name    = "Firewall config for ${var.project_name}"
    project = var.project_name
  }
}

resource "aws_key_pair" "instance_ssh_key" {
  key_name   = "ssh key pair for ${var.project_name}"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "web_server" {
  ami                         = data.aws_ami.ubuntu_latest_image_id.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.webapps.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.instance_firewall.id]
  key_name                    = aws_key_pair.instance_ssh_key.id
  user_data                   = file("bootstrap.sh")
  tags = {
    project = var.project_name
    Name    = "Web server for ${var.project_name}"
  }
}
