variable "object-name" {
    type = object({
      name = string,
      userID= number
    })
  
}

output "object-output" {
    value = var.object-name
  
}