provider "aws" {
    region = "us-east-1"
  
}

provider "aws" {
    alias = "california"
    region = "us-west-1"
}


#add dev-sg in region us-east-1 <<>> but add prod-sg to us-west-1
module "ec2" {
    source = "../../modules/sg"
    providers = {
      aws.prod = aws.california
    }
  
}
