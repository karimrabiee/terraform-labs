data "aws_ami" "latest_ubuntu_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"]
  }
  filter {
  name   = "state"
  values = ["available"]
}

}

resource "aws_instance" "web" {
  ami           = data.aws_ami.latest_ubuntu_linux.id
  instance_type = "t2.micro"
}