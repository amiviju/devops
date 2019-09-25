provider "aws" {
    region = "us-west-2"
}
###################################################### 3 layer VPC #######################################################
resource "aws_vpc" "vpc01" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-TEST"
  }
}

###################################################### SUBNET #######################################################


resource "aws_subnet" "sub01a" {
    vpc_id = "${aws_vpc.vpc01.id}"
    map_public_ip_on_launch = true
    cidr_block = "10.0.1.0/25"
    availability_zone = "us-west-2a"
    tags = {
        Name = "standard-dmz-1a-pub	"
    }
  
}
resource "aws_subnet" "sub02a" {
    vpc_id = "${aws_vpc.vpc01.id}"
    cidr_block = "10.0.2.0/25"
    availability_zone = "us-west-2a"
    tags = {
        Name = "standard-web-2a-pvt	"
    }
  
}


resource "aws_subnet" "sub03a" {
    vpc_id = "${aws_vpc.vpc01.id}"
    cidr_block = "10.0.3.0/25"
    availability_zone = "us-west-2a"
    tags = {
        Name = "standard-db-3a-pvt"
    }
  
}


resource "aws_subnet" "sub01b" {
    vpc_id = "${aws_vpc.vpc01.id}"
    map_public_ip_on_launch = true
    cidr_block = "10.0.4.0/25"
    availability_zone = "us-west-2b"
    tags = {
        Name = "standard-dmz-1b-pub"
    }
  
}
resource "aws_subnet" "sub02b" {
    vpc_id = "${aws_vpc.vpc01.id}"
    cidr_block = "10.0.5.0/25"
    availability_zone = "us-west-2b"
    tags = {
        Name = "standard-web-2b-pvt"
    }
  
}

resource "aws_subnet" "sub03b" {
    vpc_id = "${aws_vpc.vpc01.id}"
    cidr_block = "10.0.6.0/25"
    availability_zone = "us-west-2b"
    tags = {
        Name = "standard-db-3b-pvt"
    }
  
}

###################################################### RouteTable #######################################################
resource "aws_route_table" "standard-pub-rt" {
    vpc_id = "${aws_vpc.vpc01.id}"
}   
resource "aws_route_table" "standard-nat-rt" {
    vpc_id = "${aws_vpc.vpc01.id}"
}   
###################################################### RouteTable Asso #######################################################

resource "aws_route_table_association" "standard-dmz-1a-pub" {
  subnet_id      = "${aws_subnet.sub01a.id}"
  route_table_id = "${aws_route_table.standard-pub-rt.id}"
}

resource "aws_route_table_association" "standard-dmz-1b-pub" {
  subnet_id      = "${aws_subnet.sub01b.id}"
  route_table_id = "${aws_route_table.standard-pub-rt.id}"
}

resource "aws_route_table_association" "standard-db-1a-prv" {
  subnet_id      = "${aws_subnet.sub03a.id}"
  route_table_id = "${aws_route_table.standard-nat-rt.id}"
}

resource "aws_route_table_association" "standard-db-1b-prv" {
  subnet_id      = "${aws_subnet.sub03b.id}"
  route_table_id = "${aws_route_table.standard-nat-rt.id}"
}


resource "aws_route_table_association" "standard-web-1a-prv" {
  subnet_id      = "${aws_subnet.sub02a.id}"
  route_table_id = "${aws_route_table.standard-nat-rt.id}"
}

resource "aws_route_table_association" "standard-web-1b-prv" {
  subnet_id      = "${aws_subnet.sub02b.id}"
  route_table_id = "${aws_route_table.standard-nat-rt.id}"
}


###################################################### Gateways #######################################################
resource "aws_internet_gateway" "IGW01" {
  vpc_id = "${aws_vpc.vpc01.id}"

  tags = {
    Name = "igw01"
  }
}
resource "aws_nat_gateway" "natgw01" {
  allocation_id = "${aws_eip.natIP.id}"
  subnet_id     = "${aws_subnet.sub01a.id}"

  tags = {
    Name = "gw NAT"
  }
}
resource "aws_eip" "natIP" {
    vpc = true
}    


########################################## Route Rule ##################################################################
resource "aws_route" "pub_route" {
  route_table_id            = "${aws_route_table.standard-pub-rt.id}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id  = "${aws_internet_gateway.IGW01.id}"
}

resource "aws_route" "prt_route" {
  route_table_id            = "${aws_route_table.standard-nat-rt.id}"
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id  = "${aws_nat_gateway.natgw01.id}"
}
###################################################### Instance #######################################################
resource "aws_instance" "web" {
  ami           = "ami-06f2f779464715dc5"
  instance_type = "t2.micro"
  key_name  = "rean_ami.viju_20171221"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]
  subnet_id = "${aws_subnet.sub01a.id}"
  user_data = "${file("install_apache.sh")}"
  tags = {
    Name = "WebServer"
    Environment = "Development"
    ExpirationDate = "2019-10-10"
    Project = "REANPlatform"
    Owner = "asmi.viju"
  }
}

###################################################### SecurityGroup #######################################################
resource "aws_security_group" "web-sg" {
  name = "web-sg"
  description = "Allow http and https"
  vpc_id = "${aws_vpc.vpc01.id}"
 
   egress {
      from_port = 0
      to_port = 0
      protocol ="-1"
      cidr_blocks = ["0.0.0.0/0"]
  }


  ingress{
      from_port = 80
      to_port = 80
      protocol ="tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "HTTP Allow"
  }
  ingress{
      from_port = 443
      to_port = 443
      protocol ="tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "HTTPS Allow"
  }
}
