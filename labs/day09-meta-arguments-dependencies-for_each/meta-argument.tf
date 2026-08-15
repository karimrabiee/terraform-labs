data "aws_ami" "latest_ubuntu_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"]
  }
  filter {
  name   = "state"
  values = ["available"]
}

}

variable "names" {
    type = list(string)
    default = ["ec2-1","ec2-2","ec2-3"]
}

resource "aws_instance" "web" {
    ami = "ami-04fca11ec6cc2ddab"
    instance_type = "t3.micro"
    subnet_id   = "subnet-0be8e2e22a0bac3b0"

    tags = {
      name = var.names[count.index]
    }

    lifecycle {
      ignore_changes = all
      prevent_destroy = false
      create_before_destroy = false
    }
    count = 3
  
}


