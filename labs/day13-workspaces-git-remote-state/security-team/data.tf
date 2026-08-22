data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "kareem-eip.tfstate"
    key    = "production.tfstate"
    region = "us-east-1"
    }
  }

