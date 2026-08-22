terraform {
  required_providers {
    aws = {
      version = "6.6"
      source  = "hashicorp/aws"
      configuration_aliases = [ aws.prod ]
    }
  }
}

provider "aws" {
  region = "us-east-1"

}

resource "aws_security_group" "prod" {
    name = "prod-sg"
    provider = aws.prod
  
}

resource "aws_security_group" "dev"{
    name = "dev-sg"
    
}