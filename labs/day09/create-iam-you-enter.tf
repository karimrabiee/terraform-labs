
variable "iam_user" {
    type = list(string)  
    default = [ "mohamed","kareem","kareem" ]
}
/*
resource "aws_iam_user" "users" {
    name = var.iam_user[count.index]
    count = length(var.iam_user)
}
*/
output "user-name" {
    value=var.iam_user[0]
  
}

variable "iam_users" {
    type = set(string)  
    default = [ "mohamed","kareem","kareem" ]
}
output "users-name" {
    value=var.iam_users
    
  
}