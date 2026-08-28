# If a resource block includes a for_each argument whose value is a map or a set
# of strings, Terraform creates one instance for each member of that map or set.
variable "instance_config" {
  type = map
  default = {
    instance1 = { instance_type = "t3.micro", ami = "ami-02b64aa047cb5edf5" }
    instance2 = { instance_type = "t3.small", ami = "ami-0332d564d76dbd8d6" }
    instance3 = { instance_type = "t3.large", ami = "ami-0b6d9d3d33ba97d99" }
  }
}

resource "aws_instance" "k1" {
  for_each = var.instance_config
  ami           = each.value.ami
  instance_type = each.value.instance_type
  subnet_id   = "subnet-0be8e2e22a0bac3b0"
  
  tags = {
    Name = each.key
  }
}