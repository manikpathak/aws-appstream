resource "aws_vpc" "main_vpc" {
  cidr_block       = "10.1.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.1.2.0/24"

  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_internet_gateway" "main_vpc_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-VPC - igw"
  }
}

resource "aws_route_table" "main_vpc_public" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_vpc_igw.id
    }

    tags = {
        Name = "Public Subnet Route Table."
    }
}

resource "aws_route_table_association" "main_vpc_public" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.main_vpc_public.id
}
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_ssh_from_home" {
  name        = "allow_ssh_from_home_sg"
  description = "Allow SSH inbound connections from home"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.home_ip
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_from_home_sg"
  }
}

resource "aws_security_group" "allow_rdp_from_home" {
  name        = "allow_rdp_from_home_sg"
  description = "Allow RDP inbound connections from home"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.home_ip
  }

  tags = {
    Name = "allow_rdp_from_home_sg"
  }
}