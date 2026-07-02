# required inputs
variable "function_name" {
  description = "Name of the Lambda function. Also used to name the log group, IAM role, policy and security group."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC the Lambda function is attached to."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs the Lambda function is placed in."
  type        = list(string)
}

# optional inputs
variable "image_uri" {
  description = "ECR container image URI used as the Lambda source (including tag or digest)."
  type        = string
  default     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
}

variable "memory_size" {
  description = "Memory in MB allocated to the function."
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Function timeout in seconds."
  type        = number
  default     = 30
}

variable "architectures" {
  description = "Instruction set architecture for the function. Must match the image."
  type        = list(string)
  default     = ["x86_64"]
}

variable "environment_variables" {
  description = "Non-sensitive environment variables for the function. Do not put secrets here."
  type        = map(string)
  default     = {}
}

variable "log_retention_in_days" {
  description = "Retention period in days for the CloudWatch Log Group."
  type        = number
  default     = 30
}

variable "log_kms_key_arn" {
  description = "Optional KMS key ARN to encrypt the log group. Null uses AWS-owned encryption."
  type        = string
  default     = null
}

variable "egress_port" {
  description = "Outbound TCP port allowed by the security group."
  type        = number
  default     = 443
}

variable "egress_cidr" {
  description = "Destination CIDR for outbound traffic from the security group."
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  description = "Tags applied to all resources created by the module."
  type        = map(string)
  default     = {}
}
