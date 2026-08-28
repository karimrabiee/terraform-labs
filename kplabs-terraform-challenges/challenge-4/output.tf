data "aws_iam_users" "example" {}

output "iam_users" {
  value = data.aws_iam_users.example.names
}

output "number_of_users" {
    value = length(data.aws_iam_users.example.names)
  
}