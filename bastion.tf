provider "aws" {
  region                  = "ap-south-1"
  profile                 = "sahil123"
}
resource "aws_vpc" "sahil-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "sahil-vpc"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.sahil-vpc.id}"

  tags = {
    Name = "sahil-gateway"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = "${aws_vpc.sahil-vpc.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sahil-public-subnet"
  }
}
resource "aws_subnet" "private-subnet" {
  vpc_id     = "${aws_vpc.sahil-vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "sahil-private-subnet"
  }
}
resource "aws_route_table" "routing-table" {
  vpc_id = "${aws_vpc.sahil-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.routing-table.id
}
resource "aws_eip" "sahil-eip" {
  vpc      = true
}
resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = "${aws_eip.sahil-eip.id}"
  subnet_id     = "${aws_subnet.public-subnet.id}"

  tags = {
    Name = "sahil-NAT"
  }
}
resource "aws_route_table" "nat-routing-table" {
  vpc_id = "${aws_vpc.sahil-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat-gateway.id}"
  }
}
resource "aws_route_table_association" "nat-association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.nat-routing-table.id
}
resource "aws_security_group" "bastion-sg" {
  name        = "bastion-sg"
  description = "Allow ssh from public world outside"
  vpc_id      = "${aws_vpc.sahil-vpc.id}"

  ingress {
    description = "allow port 22"
    from_port   = 22
    to_port     = 22
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
    Name = "bastion-sg"
  }
}
resource "aws_security_group" "wordpress-sg" {
  name        = "wordpress-sg"
  description = "Allow  ssh and httpd"
  vpc_id      = "${aws_vpc.sahil-vpc.id}"

  ingress {
    description = "allow httpd from public world"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "allow ssh from public world"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_port_80"
  }
}
resource "aws_security_group" "mysql" {
  name        = "mysql-sg"
  description = "Allow port 3306 and sg of wordpress"
  vpc_id      = "${aws_vpc.sahil-vpc.id}"

  ingress {
    description = "allow 3306"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.wordpress-sg.id}"]
  }
 ingress {
    description = "allow ssh from public world"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.bastion-sg.id}"]
    
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysql-sg"
  }
}
resource "aws_instance" "bastion-os" {
  ami             = "ami-0ebc1ac48dfd14136"
  instance_type   = "t2.micro"
  key_name        = "mykey11"
  vpc_security_group_ids = ["${aws_security_group.bastion-sg.id}"]
  subnet_id       ="${aws_subnet.private-subnet.id}"
  tags = {
    Name = "sahil-bastion"
  }
}

resource "aws_instance" "mysql-server" {
  ami             = "ami-0019ac6129392a0f2"
  instance_type   = "t2.micro"
  key_name        = "mykey11"
  vpc_security_group_ids = ["${aws_security_group.mysql.id}"]
  subnet_id       ="${aws_subnet.private-subnet.id}"
  tags = {
    Name = "sahil-mysql"
  }
 
}
resource "aws_instance" "wordpress-server" {
  ami             = "ami-000cbce3e1b899ebd"
  instance_type   = "t2.micro"
  key_name        = "mykey11"
  vpc_security_group_ids = ["${aws_security_group.wordpress-sg.id}"]
  subnet_id        = "${aws_subnet.public-subnet.id}"
  tags = {
    Name = "sahil-wordpress"
  }
}

