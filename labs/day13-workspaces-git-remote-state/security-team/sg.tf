resource "aws_security_group" "sg11" {
    name="sg11"
  
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.sg11.id
  cidr_ipv4         = "${data.terraform_remote_state.vpc.outputs.public-ip}/32"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}