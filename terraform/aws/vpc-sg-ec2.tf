provider "aws"{
  region = "us-east-2"
  access_key = ""
  secret_key = ""
}
resource "aws_vpc" "test-vpc"{
  cidr_block = "10.0.0.0/24"
  enable_dns_hostnames = "true"
  tags = {
    Name = "test-vpc"
  }
}
resource "aws_internet_gateway" "test-ig"{
  vpc_id = aws_vpc.test-vpc.id
  tags = {
    Name = "test-ig"
  }
}
resource "aws_subnet" "test-pub-sub"{
  vpc_id = aws_vpc.test-vpc.id
  cidr_block = "10.0.0.0/28"
  availability_zone = "us-east-2a"
  tags = {
    Name = "test-pub-sub"
  }
}
resource "aws_route_table" "test-pub-sub-rt"{
  vpc_id = aws_vpc.test-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-ig.id
  }
  tags = {
    Name = "test-pub-sub-rt"
  }
}
resource "aws_route_table_association" "test-pub-sub-rt-asso"{
  subnet_id = aws_subnet.test-pub-sub.id
  route_table_id = aws_route_table.test-pub-sub-rt.id
}
resource "aws_security_group" "test-sg"{
  name = "test-sg"
  description = "enable port 22,80,8080"
  vpc_id = aws_vpc.test-vpc.id
  ingress {
    description = "enable ssh port"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "enable http port"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "enable jenkins port"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "enable all port"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "test-sg"
  }
}
resource "aws_instance" "controller-machine"{
  instance_type = "t2.small"
  ami = "ami-09040d770ffe2224f"
  key_name = "keypair-aws"
  associate_public_ip_address = true
  subnet_id = aws_subnet.test-pub-sub.id
  vpc_security_group_ids = [aws_security_group.test-sg.id]
  tags = {
    Name = "controller-machine"
  }
}
resource "aws_instance" "kube-master"{
  instance_type = "t2.medium"
  ami = "ami-09040d770ffe2224f"
  key_name = "keypair-aws"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.test-sg.id]  
  subnet_id = aws_subnet.test-pub-sub.id
  tags = {
    Name = "kube-master"
  }
}
resource "aws_instance" "slave1"{
  instance_type = "t2.micro"
  ami = "ami-09040d770ffe2224f"
  key_name = "keypair-aws"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.test-sg.id]
  subnet_id = aws_subnet.test-pub-sub.id
  tags = {
    Name = "slave1"
  }
}
