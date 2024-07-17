provider "aws" {
  region = "us-east-1"  
}

resource "aws_instance" "ansible_master" {
  ami           = "ami-04a81a99f5ec58529"
  instance_type = "t2.small"
  key_name = "my-keypair"
  user_data = file("install_ansible.sh")

  tags = {
    Name = "AnsibleMaster"
  }
}

resource "aws_instance" "instance_1" {
  ami           = "ami-04a81a99f5ec58529"
  instance_type = "t2.micro"
  key_name = "my-keypair"

  tags = {
    Name = "Instance1"
  }
}

resource "aws_instance" "instance_2" {
  ami           = "ami-04a81a99f5ec58529"
  instance_type = "t2.micro"
  key_name = "my-keypair"
  tags = {
    Name = "Instance2"
  }
}

output "ansible_master_public_ip" {
  value = aws_instance.ansible_master.public_ip
}

output "instance_1_public_ip" {
  value = aws_instance.instance_1.public_ip
}

output "instance_2_public_ip" {
  value = aws_instance.instance_2.public_ip
}
