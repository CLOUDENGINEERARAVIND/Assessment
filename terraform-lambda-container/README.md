# terraform-lambda-container

Terraform module that creates a Lambda function from a container image, running in a VPC.
It also creates the IAM role and policy, a security group, and the CloudWatch log group.

The IAM policy is written by hand (no AWS managed policies) and only allows the function to
write logs and to manage the VPC network interfaces it needs. The security group has no
inbound rules and only allows outbound HTTPS.

## Usage

```hcl
module "lambda" {
  source = "./terraform-lambda-container"

  function_name      = "my-app"
  image_uri          = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
  vpc_id             = "vpc-0abc1234def567890"
  private_subnet_ids = ["subnet-0aaa111", "subnet-0bbb222"]

  environment_variables = {
    LOG_LEVEL = "INFO"
  }

  tags = {
    Environment = "prod"
    Team        = "platform"
  }
}
```

```
terraform init
terraform plan
terraform apply
```

## Requirements

Terraform >= 1.3 and AWS provider >= 5.0. The image in image_uri must already exist in ECR.

## Inputs

Required:

- function_name - name of the function. Also used for the role, policy, security group and log group.
- vpc_id - VPC to attach the function to.
- private_subnet_ids - list of private subnet IDs for the function.

Optional (defaults shown):

- image_uri - container image URI. Placeholder default.
- memory_size - memory in MB. Default 512.
- timeout - timeout in seconds. Default 30.
- architectures - x86_64 or arm64. Default ["x86_64"].
- environment_variables - map of non-sensitive env vars. Default {}.
- log_retention_in_days - log retention. Default 30.
- log_kms_key_arn - KMS key ARN to encrypt logs. Default null.
- egress_port - outbound port allowed by the security group. Default 443.
- egress_cidr - outbound CIDR allowed by the security group. Default 0.0.0.0/0.
- tags - tags added to all resources. Default {}.

## Outputs

- function_arn, function_name, function_invoke_arn, function_qualified_arn
- role_arn, role_name, policy_arn
- security_group_id
- log_group_name, log_group_arn

## Notes

Do not put secrets in environment_variables. Use Secrets Manager or SSM and read them at runtime.
The EC2 network interface permissions in the policy are required for a Lambda that runs in a VPC.
