terraform {
  # The Central Brain: Remote State in S3
  backend "s3" {
    bucket         = "perma-memory"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# The Gatekeeper: Security Group
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-automated-sg"
  description = "Allow SSH and Jenkins"

  ingress {
    from_port   = 22
    to_port     = 22
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
}

# The Server: EC2 Instance
resource "aws_instance" "jenkins_server" {
  ami                    = "ami-0ecb62995f68bb549"
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = "tejav"

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y openjdk-17-jre
              sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
              echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt update -y
              sudo apt install -y jenkins
              sudo apt install -y docker.io
              sudo usermod -aG docker jenkins
              sudo usermod -aG docker ubuntu
              sudo systemctl enable --now docker
              sudo systemctl enable --now jenkins
              EOF

  tags = {
    Name = "Jenkins-Automated-Server"
  }
}
