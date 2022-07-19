# Create a VPC
resource "aws_vpc" "DEV-VPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    "Name" = "DEV-VPC"
  }
  
}

#public subnet
resource "aws_subnet" "Public-DEV-VPC-SN" {
  vpc_id = aws_vpc.DEV-VPC.id
  cidr_block = "10.0.10.0/24"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "public-subnet"
  }
  depends_on = [
    aws_vpc.DEV-VPC
  ]

}

#private subnet
resource "aws_subnet" "Private-DEV-VPC-SN" {
  vpc_id = aws_vpc.DEV-VPC.id
  cidr_block = "10.0.20.0/24"
  tags = {
    "Name" = "private-subnet"
  }
  depends_on = [
    aws_vpc.DEV-VPC
  ]

}

#Internet Gateway
resource "aws_internet_gateway" "IGW-DEV" {
  vpc_id = aws_vpc.DEV-VPC.id
  tags = {
    "Name" = "IGW-DEV"
  }
  depends_on = [
    aws_vpc.DEV-VPC,
    aws_subnet.Private-DEV-VPC-SN,
  ]
}

#Elastic public IP
resource "aws_eip" "DEV-NAT-EIP" {
  vpc = true
  tags = {
    "Name" = "DEV-EIP"
  }
}

#NAT Gateway
resource "aws_nat_gateway" "DEV-NAT-GW" {
  allocation_id = aws_eip.DEV-NAT-EIP.id
  subnet_id = aws_subnet.Public-DEV-VPC-SN.id
  tags = {
    "Name" = "Dev-NAT-GW"
  }
  depends_on = [
    aws_subnet.Public-DEV-VPC-SN,
    aws_eip.DEV-NAT-EIP,
  ]
}

resource "aws_route_table" "Public-RT" {
  vpc_id = aws_vpc.DEV-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW-DEV.id
  }

  tags = {
    Name = "Public-RT"
  }
}


resource "aws_route_table" "Private-RT" {
  vpc_id = aws_vpc.DEV-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.DEV-NAT-GW.id
  }

  tags = {
    Name = "Private-RT"
  }
}

#associate route-table public
resource "aws_route_table_association" "RT-Associate-Public" {
  subnet_id = aws_subnet.Public-DEV-VPC-SN.id
  route_table_id = aws_route_table.Public-RT.id

}
resource "aws_route_table_association" "RT-Associate-Private" {
  subnet_id = aws_subnet.Private-DEV-VPC-SN.id
  route_table_id = aws_route_table.Private-RT.id

}

