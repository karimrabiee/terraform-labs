provider "aws" {
    region = "us-east-1"
  
}

provider "aws" {
  alias = "west1"
  region = "us-west-1"
}

provider "aws" {
    alias = "west2"
    region = "us-west-2"
  
}

resource "aws_security_group" "sg-1" {
    name="sga" 
}

resource "aws_security_group" "sg-2" {
    name="sgb"
    provider = aws.west1 
}

resource "aws_security_group" "sg-3" {
    name="sgc" 
    provider = aws.west2
}
