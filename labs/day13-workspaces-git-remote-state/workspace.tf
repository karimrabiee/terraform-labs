
resource "aws_instance" "myec2" {
    instance_type = local.instance_type[terraform.workspace]
    ami = "ami-04fca11ec6cc2ddab"
    subnet_id = "subnet-0be8e2e22a0bac3b0"
  
}


locals {
  instance_type = {
    default = "t3.micro"
    dev = "t3.nano"
    prod = "t3.small"
  }
}
