variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {
    team = "security-team"
  }
}

locals {
    default_tags = {
        team = "security-team"
        creation-date = "date - ${formatdate("DD/MM/YYYY", timestamp())}"
    }
}

resource aws_security_group "allow_tls" {
  name        = "allow_tls"
  tags = local.default_tags
}

