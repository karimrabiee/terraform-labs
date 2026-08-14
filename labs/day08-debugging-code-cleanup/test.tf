
resource "local_file" "foo" {
    filename = "${path.module}/foo.txt"
    content = "foo"
}


resource "aws_instance" "web" {
    ami           = "ami-02b64aa047cb5edf5"
    instance_type = "t2.micro"
    subnet_id   = "subnet-0be8e2e22a0bac3b0"
    tags = {
        Name = "web"
    }
  
}



resource "aws_iam_user" "users" {
    name = "user-${count.index}"
    count = 3
}

output "user_names" {
    value = aws_iam_user.users[*].name
}

output "user_arns" {
    value = aws_iam_user.users[*].arn
}

output "zipmap_users" {
    value = zipmap(aws_iam_user.users[*].name,aws_iam_user.users[*].arn)
}


