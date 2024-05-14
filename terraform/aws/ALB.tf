provider "aws" {
  access_key = "" 
  secret_key = ""
  region = "us-east-2" 
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for Application Load Balancer"
  
  # Define ingress rules (adjust as per your requirements)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Define egress rules (adjust as per your requirements)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false  # Set to true for internal ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  # Specify subnets where the ALB will be provisioned
  subnets            = ["subnet-058c48067449e8a19", "subnet-0570983d4abe617f9"]  # Replace with your subnet IDs

  # Tags (optional)
  tags = {
    Name = "my-alb"
  }
}

resource "aws_lb_listener" "my_alb_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.my_target_group.arn
    type             = "forward"
  }
}


resource "aws_lb_target_group" "my_target_group" {
  name        = "my-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-0906a04f7e01337b3"  # Replace with your VPC ID

  # Health check configuration (adjust as per your requirements)
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = 80
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
resource "aws_lb_target_group_attachment" "my_target_attachment1" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = "i-0e1a54ea26f44f728"  # Replace with your target ID
  port             = 80
}

resource "aws_lb_target_group_attachment" "my_target_attachment2" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = "i-04df4a0566d66a960"  # Replace with your target ID
  port             = 80
}
