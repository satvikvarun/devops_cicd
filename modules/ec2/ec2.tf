variable "subnets" {}
variable "frontend_sg" {}
variable "backend_sg" {}
variable "rds_endpoint" {}
variable "db_username" {}
variable "db_password" {}
variable "dockerhub_username" {}

data "aws_ami" "amazon_linux_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"]
  }
}


# Frontend EC2

resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.amazon_linux_arm.id
  instance_type          = "t4g.medium"
  subnet_id              = var.subnets[0]
  vpc_security_group_ids = [var.frontend_sg]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker

              docker pull ${var.dockerhub_username}/cloud-notes-frontend:latest
              docker run -d -p 80:80 ${var.dockerhub_username}/cloud-notes-frontend:latest
              EOF

  tags = {
    Name = "3tier-frontend"
  }
}


# Backend EC2

resource "aws_instance" "backend" {
  ami                    = data.aws_ami.amazon_linux_arm.id
  instance_type          = "t4g.medium"
  subnet_id              = var.subnets[1]
  vpc_security_group_ids = [var.backend_sg]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker

              docker pull ${var.dockerhub_username}/cloud-notes-backend:latest
              docker run -d -p 8080:8080 \
                -e DB_HOST=${var.rds_endpoint} \
                -e DB_USER=${var.db_username} \
                -e DB_PASSWORD=${var.db_password} \
                -e DB_NAME=postgres \
                ${var.dockerhub_username}/cloud-notes-backend:latest
              EOF

  tags = {
    Name = "3tier-backend"
  }
}

output "frontend_id" {
  value = aws_instance.frontend.id
}

output "backend_id" {
  value = aws_instance.backend.id
}
