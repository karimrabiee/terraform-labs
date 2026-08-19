provider "aws" {
    region = "us-east-1"
  
}

module "ec2" {
    source = "../../modules/ec2"
    instance_type = "t2.micro"
    subnet = "subnet-0be8e2e22a0bac3b0"
    ami = "ami-04fca11ec6cc2ddab"
  
}

resource "aws_eip" "lb" {
  instance = module.ec2.instnce_id

}

