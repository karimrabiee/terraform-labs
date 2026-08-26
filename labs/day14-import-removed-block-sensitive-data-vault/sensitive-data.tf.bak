variable "passwd_content" {
    sensitive = true
    default = "fsfVF43%$#GTDGD"
  
}

resource "local_sensitive_file" "passwd" {
  content = var.passwd_content
  filename = "${path.module}/passwd.txt"
}

output "password" {
    value = local_sensitive_file.passwd.content
    sensitive = true
  
}

variable "user_name" {
  default = "foo"
  sensitive = true
}

variable "db_passwd" {
    default = "foobarbaz"
    sensitive = true
  
}
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  
}