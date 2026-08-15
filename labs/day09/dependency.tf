#explicit dependency
resource "aws_instance" "web2" {
    ami = "ami-04fca11ec6cc2ddab"
    instance_type = "t3.micro"
    subnet_id   = "subnet-0be8e2e22a0bac3b0"
    #there is not attribute of other resources (s3 bucket so we use explicit)
    depends_on = [ aws_s3_bucket.bucket1 ]

  
}

resource "aws_s3_bucket" "bucket1" {
    bucket = "kareem-213"
  
}

#implicit dependency
resource "aws_instance" "web3" {
    ami = "ami-04fca11ec6cc2ddab"
    instance_type = "t3.micro"
    subnet_id   = "subnet-0be8e2e22a0bac3b0"
    #argument with attribute of other resources (so we use implicit)
    vpc_security_group_ids = [ "aws_security_group.sg1.id" ]

  
}

resource "aws_security_group" "sg1" {
    name = "security-group1"
  
}