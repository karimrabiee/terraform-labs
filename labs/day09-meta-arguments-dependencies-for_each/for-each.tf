variable "amies"{
    default = {
        dev="ami-123"
        prod="ami-678"
    }
}

resource "aws_instance" "web3" {
    for_each = var.amies
    ami = each.value
    instance_type = "t3.micro"
    subnet_id   = "subnet-0be8e2e22a0bac3b0"
    
    tags = {
      name=each.key
    }

}

variable "iam_user_names" {
    type = set(string)
    default = [ "kareem","mohamed","ahmed","kareem" ]
    #we use set not list bacause set remove dublicate names but list not do that
    #because we use set we use for_each for multiple users not count
  
}

resource "aws_iam_user" "name" {
  for_each = var.iam_user_names
  name = each.value
}