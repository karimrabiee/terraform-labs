# instead of one EC2 instance, create 3 using for_each instead of count

variable "instance-types" {
    default =  {
        dev="t2.micro"
        test="t2.nano"
        production="t2.small"
    }
  
}

resource "aws_instance" "chalenge" {
    for_each = var.instance-types
    ami = "ami-04fca11ec6cc2ddab"
    instance_type =each.value
    subnet_id   = "subnet-0be8e2e22a0bac3b0"
    tags = {
        name=each.key
    }

}