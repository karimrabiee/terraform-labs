variable "ingress_rules" {
  type = list(number)
  default = [80,22,21]
}

resource "aws_security_group" "sg1" {
    name        = "sg1"
    description = "Security group 1"
    dynamic "ingress" {
        for_each = var.ingress_rules
        content {
            from_port   = ingress.value
            to_port     = ingress.value
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
}
