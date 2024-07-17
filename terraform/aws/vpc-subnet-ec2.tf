provider "aws" {
  access_key = ""
  secret_key = ""
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}
resource "aws_internet_gateway" "main-ig" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "main-ig"
    }
}


# Setting up the route table
resource "aws_route_table" "pub-rt" {
    vpc_id = aws_vpc.main.id
    route {
        # pointing to the internet
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main-ig.id
    }
    route {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.main-ig.id
    }
    tags = {
        Name = "pub-rt"
    }
}

# Create a subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "main-subnet"
  }
}
# Associating the subnet with the route table
resource "aws_route_table_association" "pub-sub-rt-assoc" {
    subnet_id = aws_subnet.main.id
    route_table_id = aws_route_table.pub-rt.id
}

# Create a security group
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "instance-sg"
  }
}

# Create the first instance as t2.medium
resource "aws_instance" "web_medium" {
  ami           = "ami-04a81a99f5ec58529" # Example AMI, update as needed
  instance_type = "t2.medium"
  key_name = "my-keypair"
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  tags = {
    Name = "web-instance-1"
  }
}

# Create the other two instances as t2.micro
resource "aws_instance" "web_micro" {
  count         = 2
  key_name = "my-keypair"
  ami           = "ami-04a81a99f5ec58529" # Example AMI, update as needed
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  tags = {
    Name = "web-instance-${count.index + 2}"
  }
}

# Associate Elastic IPs with the instances
resource "aws_eip" "web_medium_eip" {
  instance = aws_instance.web_medium.id

  tags = {
    Name = "web-eip-1"
  }
}

resource "aws_eip" "web_micro_eip" {
  count    = 2
  instance = element(aws_instance.web_micro[*].id, count.index)

  tags = {
    Name = "web-eip-${count.index + 2}"
  }
}

