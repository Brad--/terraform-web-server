variable "access_key" {
    description = "AWS Access Key"
    type        = string
}

variable "secret_key" {
    description = "AWS Secret Key"
    type        = string
}

# End Variables

provider "aws" {
    region = "us-east-1"
    
    access_key = var.access_key
    secret_key = var.secret_key
}

resource "aws_vpc" "prod_vpc" {
    cidr_block = "10.0.0.0/16"
    
    tags = {
        Name = "Prod VPC"
    }
}

resource "aws_internet_gateway" "prod_gw" {
    vpc_id = aws_vpc.prod_vpc.id
    
    tags = {
        Name = "Prod Gateway"
    }
}

resource "aws_egress_only_internet_gateway" "prod_egress" {
    vpc_id = aws_vpc.prod_vpc.id

    tags = {
        Name = "Prod Egress"
    }
}

resource "aws_subnet" "prod_subnet" {
    vpc_id              = aws_vpc.prod_vpc.id
    cidr_block          = "10.0.1.0/24"
    availability_zone   = "us-east-1a"

    tags = {
        Name = "Prod Subnet"
    }
}

resource "aws_route_table_association" "prod_subnet_assoc" {
    subnet_id       = aws_subnet.prod_subnet.id
    route_table_id  = aws_route_table.prod_route_table.id
}

resource "aws_security_group" "prod_security_group" {
    vpc_id      = aws_vpc.prod_vpc.id
    name        = "allow_tls"
    description = "allow Web traffic inbound"

    ingress {
        description = "HTTPS Traffic"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTP Traffic"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Allow Web Traffic & SSH"
    }
    
}

resource "aws_route_table" "prod_route_table" {
    vpc_id = aws_vpc.prod_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.prod_gw.id
    }

    route {
        ipv6_cidr_block         = "::/0"
        egress_only_gateway_id  = aws_egress_only_internet_gateway.prod_egress.id
    }

    tags = {
        Name = "Prod routes"
    }
}

resource "aws_network_interface" "prod_nic" {
    subnet_id       = aws_subnet.prod_subnet.id
    private_ips     = ["10.0.1.50"]
    security_groups = [aws_security_group.prod_security_group.id]
}

resource "aws_eip" "prod_eip" {
    vpc = true
    network_interface = aws_network_interface.prod_nic.id
    associate_with_private_ip = "10.0.1.50"
    depends_on = [aws_internet_gateway.prod_gw]
}

resource "aws_instance" "web_server" {
    ami             = "ami-0bcc094591f354be2"
    instance_type   = "t2.micro"
    availability_zone = aws_subnet.prod_subnet.availability_zone
    key_name = "tf-prod-key"
    
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.prod_nic.id
    }

    user_data = "${file("on-start.sh")}"

    depends_on = [aws_internet_gateway.prod_gw]
    tags = {
        Name = "TF Ubuntu Web Server"
    }
}