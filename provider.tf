terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
# Create bucket
resource "aws_s3_bucket" "basicstorage" {
  bucket = "999bucket999"
}
# Create DynamoDB table
resource "aws_dynamodb_table" "basic-dynamodb-table"{
name = "mydynamodbtable"
billing_mode = "PAY_PER_REQUEST"
hash_key = "LockID"
attribute {
name = "LockID"
type = "S"
}
}