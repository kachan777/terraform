provider "aws" {
    region = "ap-northeast-1"
}

resource "aws_vpc" "Portal_Production" {
	cidr_block = "10.0.0.0/16"
	
	tags {
		Name = "Portal_Production"
	}
}

resource "aws_internet_gateway" "Portal_Production_Gateway" {
    vpc_id = "${aws_vpc.Portal_Production.id}"
}

resource "aws_subnet" "web_subnet" {
    vpc_id = "${aws_vpc.Portal_Production.id}"
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "db_subnet" {
    vpc_id = "${aws_vpc.Portal_Production.id}"
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-northeast-1a"
}
 
resource "aws_route_table" "Portal_Public-Route" {
    vpc_id = "${aws_vpc.Portal_Production.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.Portal_Production_Gateway.id}"
    }
}

resource "aws_route_table_association" "puclic-web" {
    subnet_id = "${aws_subnet.web_subnet.id}"
    route_table_id = "${aws_route_table.Portal_Public-Route.id}"
}

resource "aws_route_table_association" "puclic-db" {
    subnet_id = "${aws_subnet.db_subnet.id}"
    route_table_id = "${aws_route_table.Portal_Public-Route.id}"
}

resource "aws_security_group" "web_security_gp" {
    name = "web_security_gp"
    vpc_id = "${aws_vpc.Portal_Production.id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "db_security_gp" {
    name = "db_security_gp"
    vpc_id = "${aws_vpc.Portal_Production.id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 3306 
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["10.0.1.0/24"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "EN-PORTAL-PRODUCT-WEB-01" {
    ami = "ami-923d12f5"
    instance_type = "t2.micro"
    key_name = "EN-TEST-Wordpress-01"
    vpc_security_group_ids = [
      "${aws_security_group.web_security_gp.id}"
    ]
    subnet_id = "${aws_subnet.web_subnet.id}"
    associate_public_ip_address = "true"
    root_block_device = {
      volume_type = "gp2"
      volume_size = "10"
    }
    tags {
        Name = "EN-PORTAL-PRODUCT-WEB-01"
    }
}
 
output "public ip of EN-PORTAL-PRODUCT-WEB-01" {
  value = "${aws_instance.EN-PORTAL-PRODUCT-WEB-01.public_ip}"
}

