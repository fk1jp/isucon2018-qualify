data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["aws-marketplace"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "servers" {
  ami           = "${data.aws_ami.amazon_linux.id}"
  count         = 4
  instance_type = "t3.micro"
  key_name      = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  #subnet_id                   = "${aws_subnet.subnet-a.id}"
  subnet_id                   = "${element(aws_subnet.subnet-all.*.id, count.index%2)}"
  associate_public_ip_address = true
  ebs_optimized = true
  root_block_device {
    volume_type = "gp2"
    volume_size = 30
  }
  tags = {
    Name = "server${format("%02d", count.index + 1)}"
  }
}
