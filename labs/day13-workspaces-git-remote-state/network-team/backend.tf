terraform {
  backend "s3" {
    bucket = "kareem-eip.tfstate"
    key    = "production.tfstate"
    region = "us-east-1"
    use_lockfile = true
    
  }
}



