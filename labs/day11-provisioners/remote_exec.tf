
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Outbound Allowed"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "myec2" {
   ami           = "ami-0b6d9d3d33ba97d99"
   instance_type = "t3.micro"
   subnet_id     = "subnet-0be8e2e22a0bac3b0"
   key_name = "terraform-key"
   vpc_security_group_ids  = [aws_security_group.allow_ssh.id]

   provisioner "remote-exec" {
     inline = [
    "sudo apt-get update -y",
    "sudo apt-get install -y nginx",
    "sudo systemctl enable --now nginx"
       
     ]
   }

   connection {
     type = "ssh"
     user = "ubuntu"
     private_key = file("./terraform-key.pem")
     host = self.public_ip
   }
}