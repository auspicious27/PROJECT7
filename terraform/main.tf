# Simple Terraform configuration for deploying on a single EC2 instance
# This is optional and minimal - the project works without it

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Security group for the MLOps instance
resource "aws_security_group" "mlops_sg" {
  name        = "mlops-pipeline-sg"
  description = "Security group for MLOps pipeline"
  
  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }
  
  # Flask API
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Flask API"
  }
  
  # Streamlit UI
  ingress {
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Streamlit UI"
  }
  
  # Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Prometheus"
  }
  
  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "mlops-pipeline-sg"
  }
}

# EC2 instance for MLOps pipeline
resource "aws_instance" "mlops_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [aws_security_group.mlops_sg.id]
  
  user_data = <<-EOF
              #!/bin/bash
              # This script runs on instance launch
              # Install git and clone your repository here
              yum update -y
              yum install -y git
              
              # Clone repository (replace with your repo URL)
              # git clone https://github.com/your-username/mlops-pipeline.git /home/ec2-user/mlops-pipeline
              # cd /home/ec2-user/mlops-pipeline
              # chmod +x install.sh run_demo.sh
              # ./install.sh
              # ./run_demo.sh
              EOF
  
  tags = {
    Name = "mlops-pipeline-instance"
  }
}

output "instance_public_ip" {
  description = "Public IP of the MLOps instance"
  value       = aws_instance.mlops_instance.public_ip
}

output "flask_api_url" {
  description = "Flask API URL"
  value       = "http://${aws_instance.mlops_instance.public_ip}:5000"
}

output "streamlit_url" {
  description = "Streamlit UI URL"
  value       = "http://${aws_instance.mlops_instance.public_ip}:8501"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${aws_instance.mlops_instance.public_ip}:9090"
}
