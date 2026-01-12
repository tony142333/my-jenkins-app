# main.tf

terraform {
  backend "s3" {
    bucket         = "perma-memory" # <--- Your Bucket Name
    key            = "terraform.tfstate"         # Name of the state file in S3
    region         = "us-east-1"
    encrypt        = true                        # Keeps your state data secure
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Change as needed
}

# 1. Create Security Group (SSH for you, 8080 internal)
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-automated-sg"
  description = "Allow SSH and Jenkins"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For production, restrict to your IP
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

# 2. Automate Installation via User Data
resource "aws_instance" "jenkins_server" {
  ami                    = "ami-0ecb62995f68bb549" # Ubuntu 24.04 LTS (Verify for your region)
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = "tejav" # Ensure this exists in AWS

  user_data = <<-EOF
              #!/bin/bash
              # Update and Install Java + Jenkins
              sudo apt update -y
              sudo apt install -y openjdk-17-jre
              sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
              echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt update -y
              sudo apt install -y jenkins

              # Install Docker
              sudo apt install -y docker.io
              sudo usermod -aG docker jenkins
              sudo systemctl enable --now docker

              # Install ngrok
              curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
              echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
              sudo apt update && sudo apt install -y ngrok

              # Start Jenkins
              sudo systemctl enable --now jenkins
              EOF

  tags = {
    Name = "Jenkins-Automated-Server"
  }
}