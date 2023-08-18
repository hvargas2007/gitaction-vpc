#Needed to avoid the warning: reference to undefined provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-tfstate-cicd-poc-actions"
    key            = "global/actions/terraform.tfstate"
    dynamodb_table = "terraform-tfstate-cicd-poc-actions"
    region         = "us-east-1"
    encrypt        = true
  }
}
