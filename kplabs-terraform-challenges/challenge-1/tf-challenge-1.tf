/*
this solution require download terraform version 0.12.31 in an challenge-1 folder and run
./terraform version  #to ensure is the expected verion
./terraform init
./terraform plan
./terraform apply
./terraform destroy

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

*/