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
# Create backend
terraform {
  backend "s3" {
    bucket = "777bucket777"
    key    = "s3://777bucket777/devops/"
    region = "us-east-1"
    # Create DynamoDB
    dynamodb_table = "mytable"
  }
}