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