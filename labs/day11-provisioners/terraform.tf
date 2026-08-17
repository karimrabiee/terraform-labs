terraform {
  required_providers {
    aws = {
      version = "6.6"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"

}