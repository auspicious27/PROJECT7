# Terraform Configuration (Optional)

This directory contains optional Terraform configuration for deploying the MLOps pipeline on AWS EC2.

## Note

**This is completely optional.** The project works perfectly with local Docker Compose and doesn't require AWS or Terraform.

## Usage

If you want to deploy to AWS:

1. Install Terraform:
```bash
# On Amazon Linux / RHEL
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum install terraform
```

2. Configure AWS credentials:
```bash
aws configure
```

3. Initialize Terraform:
```bash
cd terraform
terraform init
```

4. Review the plan:
```bash
terraform plan
```

5. Apply the configuration:
```bash
terraform apply
```

6. Get the outputs:
```bash
terraform output
```

7. SSH into the instance and run the installation:
```bash
ssh ec2-user@<instance-ip>
# Then follow the manual installation steps
```

## Cleanup

To destroy the resources:
```bash
terraform destroy
```

## Variables

You can customize the deployment by creating a `terraform.tfvars` file:

```hcl
aws_region    = "us-west-2"
instance_type = "t3.large"
ami_id        = "ami-xxxxxxxxx"
```
