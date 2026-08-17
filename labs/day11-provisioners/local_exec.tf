resource "aws_instance" "web" {
  ami           = "ami-04fca11ec6cc2ddab"
  instance_type = "t3.micro"
  subnet_id     = "subnet-0be8e2e22a0bac3b0"

  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> server_ip.txt"
    
  }

  }

