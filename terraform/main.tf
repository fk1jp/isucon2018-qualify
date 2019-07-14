variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "VPC_name" {}
variable "public_key_path" {}
variable "allow_ips" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "ap-northeast-1"
}

resource "aws_vpc" "myVPC" {
  cidr_block           = "10.123.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = var.VPC_name
  }
}

resource "aws_internet_gateway" "myGW" {
  vpc_id = "${aws_vpc.myVPC.id}"

  tags = {
    Name = "${var.VPC_name}-GW"
  }
}

resource "aws_route_table" "public-route" {
  vpc_id = "${aws_vpc.myVPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.myGW.id}"
  }

  tags = {
    Name = "${var.VPC_name}-route"
  }
}


variable "subnets" {
    default = {
       "0" = "10.123.0.0/24"
       "1" = "10.123.1.0/24"
  }
}

variable "azs" {
    default = {
       "0" = "ap-northeast-1a"
       "1" = "ap-northeast-1c"
  }
}

resource "aws_subnet" "subnet-all" {
  vpc_id            = "${aws_vpc.myVPC.id}"
  count             = "${length(var.subnets)}"
  cidr_block        = "${lookup(var.subnets, count.index)}"
  availability_zone = "${lookup(var.azs, count.index)}"

  tags = {
    Name            = "${var.VPC_name}-${lookup(var.azs, count.index)}"
    Created         = "terraform"
  }
}

resource "aws_route_table_association" "subnet-all" {
  count          = "${length(var.subnets)}"
  subnet_id      = "${element(aws_subnet.subnet-all.*.id, count.index%2)}"
  route_table_id = "${aws_route_table.public-route.id}"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.VPC_name}_key"
  public_key = "${file(var.public_key_path)}"
}
