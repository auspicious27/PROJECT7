# Terraform variables

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for Amazon Linux 2"
  type        = string
  # Amazon Linux 2 AMI (update based on your region)
  default     = "ami-0c55b159cbfafe1f0"
}
