resource "aws_security_group" "sg2" {
    name ="sg10"
  
}

moved {
    from =aws_security_group.sg1
    to = aws_security_group.sg2
}