#...

ephemeral "random_password" "db_password" {
  length           = 16
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password_wo          = ephemeral.random_password.db_password.result
  password_wo_version  = 1
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}

