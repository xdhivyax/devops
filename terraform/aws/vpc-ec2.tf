provider "aws" {
    region = "us-east-1"
    access_key = ""
    secret_key = ""
}

# Creating a VPC
resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.0.0.0/24"
    enable_dns_hostnames = true
    tags = {
        Name = "Prod-VPC"
    }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "prod-ig" {
    vpc_id = aws_vpc.prod-vpc.id
    tags = {
        Name = "prod-ig"
    }
}

# Setting up the route table
resource "aws_route_table" "prod-pub-rt" {
    vpc_id = aws_vpc.prod-vpc.id
    route {
        # pointing to the internet
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.prod-ig.id
    }
    route {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.prod-ig.id
    }
    tags = {
        Name = "prod-pub-rt"
    }
}

# Setting up the subnet
resource "aws_subnet" "prod-pub-subnet" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.0.0.0/28"
    availability_zone = "us-east-1a"
    tags = {
        Name = "prod-pub-subnet"
    }
}

# Associating the subnet with the route table
resource "aws_route_table_association" "prod-pub-sub-rt-assoc" {
    subnet_id = aws_subnet.prod-pub-subnet.id
    route_table_id = aws_route_table.prod-pub-rt.id
}

# Creating a Security Group
resource "aws_security_group" "prod-sg" {
    name = "prod-sg"
    description = "Enable web traffic for the project"
    vpc_id = aws_vpc.prod-vpc.id
    ingress {
        description = "HTTPS traffic"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "HTTP traffic"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "SSH port"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    tags = {
        Name = "prod-sg"
    }
}


# Creating an Ubuntu EC2 instance
resource "aws_instance" "controller-machine" {
    ami = "ami-04b70fa74e45c3917"
    instance_type = "t2.medium"
    availability_zone = "us-east-1a"
    key_name = "aws-keypair"
    tags = {
        Name = "controller-machine"
    }
}

resource "aws_instance" "kube-master" {
    ami = "ami-04b70fa74e45c3917"
    instance_type = "t2.medium"
    availability_zone = "us-east-1a"
    key_name = "aws-keypair"
    tags = {
        Name = "kube-master"
    }
}

resource "aws_instance" "kube-slave" {
    ami = "ami-04b70fa74e45c3917"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    key_name = "aws-keypair"
    tags = {
        Name = "kube-slave"
    }
}

