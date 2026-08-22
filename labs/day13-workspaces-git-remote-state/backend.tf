/*
terraform {
  backend "local" {
    path = "terraform1.tfstate"
  }
}
*/
terraform {
  backend "s3" {
    bucket = "kareem-tfstate"
    key    = "production.tfstate"
    region = "us-east-1"
    use_lockfile = true
    
  }
}

resource "aws_security_group" "prod" {
  name = "prod"
}


