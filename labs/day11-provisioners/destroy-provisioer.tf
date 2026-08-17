resource "aws_instance" "myec2" {
   ami           = "ami-0b6d9d3d33ba97d99"
   instance_type = "t3.micro"
   subnet_id     = "subnet-0be8e2e22a0bac3b0"
   key_name = "terraform-key"

#this provisioner run when destroy only <<<<<<<<<
   provisioner "local-exec" {
    command = "echo1 create ec2 instance"
    on_failure = continue
       
   }

#this provisioner run when destroy only <<<<<<<<
   provisioner "local-exec" {
    when = destroy
    command = "echo destroy the instance"
     
   }
}