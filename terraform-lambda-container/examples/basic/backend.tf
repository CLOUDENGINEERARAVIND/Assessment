# Remote state backend for THIS root configuration.
# A backend belongs in the root/consuming config, never inside a reusable module.
# Values are passed at init time so the same file works across environments:
#
#   terraform init \
#     -backend-config="bucket=my-tfstate-bucket" \
#     -backend-config="key=lambda-container/dev/terraform.tfstate" \
#     -backend-config="region=us-east-1" \
#     -backend-config="dynamodb_table=terraform-locks" \
#     -backend-config="encrypt=true"
#
# The S3 bucket and DynamoDB lock table must already exist before init.
terraform {
  backend "s3" {}
}
