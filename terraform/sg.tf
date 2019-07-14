resource "aws_security_group" "sg" {
    name = "${var.VPC_name}_SG"
    vpc_id = "${aws_vpc.myVPC.id}"
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["10.193.0.0/16"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [for ip in var.allow_ips: "${ip}/32" ]
    }
    ingress {
        from_port = 39449
        to_port = 39449
        description = "ssh"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
#    ingress {
#        from_port = 443
#        to_port = 443
#        description = "https"
#        protocol = "tcp"
#        cidr_blocks = ["0.0.0.0/0"]
#    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    description = "${var.VPC_name} SG"
}

