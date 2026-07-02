# Remote state backend for THIS root configuration (S3 for state, DynamoDB for locking).
# A backend belongs in the root/consuming config, never inside a reusable module.
# The S3 bucket and the DynamoDB lock table must already exist before "terraform init"
# (create them once with a small bootstrap config or by hand).
#
# DynamoDB lock table requirement: a table with a partition key named "LockID" (String).
terraform {
  backend "s3" {
    bucket         = "my-tfstate-bucket"                    # S3 bucket holding the state file
    key            = "lambda-container/dev/terraform.tfstate" # unique path per environment
    region         = "us-east-1"                            # region of the bucket
    dynamodb_table = "terraform-locks"                      # DynamoDB table for state locking
    encrypt        = true                                   # encrypt state at rest
  }
}
