locals {
  default_tags = {
    Environment   = "development"
    creation-date = "date - ${formatdate("DD/MM/YYYY", timestamp())}"
  }
}