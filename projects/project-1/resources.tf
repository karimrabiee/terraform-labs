resource "aws_vpc" "main" {
  cidr_block = var.cidr_vpc
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidr_subnet
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.latest_ubuntu_linux.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.main.id
  count         = 3
  tags = merge(local.default_tags, {
    Name = "web-${count.index}"
  })

}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.main.id

}


resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = var.http_port
  to_port           = var.http_port
  ip_protocol       = var.tcp_port
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = var.ssh_port
  to_port           = var.ssh_port
  ip_protocol       = var.tcp_port
}


resource "aws_vpc_security_group_egress_rule" "web_sg_egress" {
  security_group_id = aws_security_group.web_sg.id
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}