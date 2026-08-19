/*
module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.4.0"
  subnet_id     = "subnet-0be8e2e22a0bac3b0"
}

*/

resource "aws_instance" "kareem" {
    subnet_id     = var.subnet
    instance_type = var.instance_type
    ami = var.ami

}




