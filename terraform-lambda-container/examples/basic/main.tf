provider "aws" {
  region = "us-east-1"
}

module "lambda_container" {
  source = "../../"

  function_name      = "example-container-fn"
  image_uri          = "123456789012.dkr.ecr.us-east-1.amazonaws.com/example:latest"
  vpc_id             = "vpc-0abc1234def567890"
  private_subnet_ids = ["subnet-0aaa111", "subnet-0bbb222"]

  memory_size = 512
  timeout     = 30

  environment_variables = {
    LOG_LEVEL = "INFO"
  }

  tags = {
    Environment = "dev"
    Project     = "platform"
  }
}

output "function_arn" {
  value = module.lambda_container.function_arn
}

output "security_group_id" {
  value = module.lambda_container.security_group_id
}
