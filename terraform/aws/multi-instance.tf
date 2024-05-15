provider "aws" {
  access_key = ""
  secret_key = ""
  region = "us-east-1"
}

resource "aws_instance" "ubuntu-instance"{
  ami = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  key_name = "keypair"
  tags = {
    Name = "ubuntu"
  }
}

resource "aws_instance" "amazon-linux2-instance"{
  ami = "ami-04ff98ccbfa41c9ad"
  key_name = "keypair"
  instance_type = "t2.micro"
  tags = {
    Name = "amazon-linux2"
  }
}

resource "aws_instance" "redhat-linux-instance"{
  ami = "ami-0fe630eb857a6ec83"
  instance_type = "t2.micro"
  key_name = "keypair"
  tags = {
    Name = "redhat-linux"
  }
}
