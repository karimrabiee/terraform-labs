What you need to do?
1. Create Infrastructure using the provided code (without modifications).
2. Verify if the code works in the latest version of Terraform and Provider .
3. Modify and Fix the code so that it works with latest version of Terraform.
4. Feel free to edit the code as you like


provider "aws" {
 version = "~> 2.54"
 region = "us-east-1"
}

provider "digitalocean" {}

terraform {
  required_version = "0.12.31"
}

resource "aws_eip" "kplabs_app_ip" {
 vpc = true
}