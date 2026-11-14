variable "db_password" {
    type = string
    description = "the password for db"

    validation {
      condition = length(var.db_password) >=12
      error_message = "the password must be greater than or equal to 12 character"
    }
  
}
