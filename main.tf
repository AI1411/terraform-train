resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    tags =  {
        Name = "tf-vpc"
    }
}

resource "aws_subnet" "tf-public-subnet-a" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"

    tags = {
        Name = "tf-public-subnet-a"
    }
}

resource "aws_subnet" "tf-public-subnet-c" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"

    tags = {
        Name = "tf-public-subnet-c"
    }
}

resource "aws_subnet" "tf-private-subnet-a" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.11.0/24"

    tags = {
        Name = "tf-private-subnet-a"
    }
}

resource "aws_subnet" "tf-private-subnet-c" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.12.0/24"

    tags = {
        Name = "tf-private-subnet-c"
    }
}

resource "aws_internet_gateway" "tf-internet-gateway" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "tf-internet-gateway"
    }
}

resource "aws_route_table" "tf-public-rtb" {
    vpc_id = aws_vpc.main.id

   tags = {
        Name = "tf-public-rtb"
   }
}

resource "aws_route_table" "tf-private-rtb" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "tf-private-rtb"
    }
}

resource "aws_route" "tf-public-route" {
    destination_cidr_block = "0.0.0.0/0"
    route_table_id = aws_route_table.tf-public-rtb.id
    gateway_id = aws_internet_gateway.tf-internet-gateway.id
}

resource "aws_route_table_association" "tf-public-rtb-a" {
    subnet_id = aws_subnet.tf-public-subnet-a.id
    route_table_id = aws_route_table.tf-public-rtb.id
}

resource "aws_route_table_association" "tf-public-rtb-c" {
    subnet_id = aws_subnet.tf-public-subnet-c.id
    route_table_id = aws_route_table.tf-public-rtb.id
}

resource "aws_route_table_association" "tf-private-rtb-a" {
    subnet_id = aws_subnet.tf-private-subnet-a.id
    route_table_id = aws_route_table.tf-private-rtb.id
}

resource "aws_route_table_association" "tf-private-rtb-c" {
    subnet_id = aws_subnet.tf-private-subnet-c.id
    route_table_id = aws_route_table.tf-private-rtb.id
}

resource "aws_instance" "web" {
    tags = {
        Name = "tf-ec2-instance"
    }
    ami = "ami-0ecb2a61303230c9d"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.tf-public-subnet-a.id
    associate_public_ip_address = true
    key_name = aws_key_pair.key_pair.id
    vpc_security_group_ids = [aws_security_group.main.id]

    user_data = <<EOF
        #!/bin/bash
        yum -y update
        yum -y install httpd
        systemctl enable httpd.service
        systemctl start httpd.service
    EOF
}

resource "aws_security_group" "main" {
    name = "tf-security-group"
    description = "tf-security-group"
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "public_ip" {
    value = aws_instance.web.public_ip
}
