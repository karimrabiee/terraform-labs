data "local_file" "kareem" {
  filename = "${path.module}/kareem.txt"
}

output "kareem" {
  value = data.local_file.kareem.content
}

data "aws_security_group" "sg" {
}



output "sg_id" {
  value = data.aws_security_group.sg.arn
}



data "aws_instance" "web" {
filter {
    name   = "tag:environment"
    values = ["dev"]
  }  

}

