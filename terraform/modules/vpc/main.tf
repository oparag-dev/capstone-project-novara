resource "aws_vpc" "this" {
  cidr_block           =  var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name     = "${var.project_name}-vpc"
    Project  = var.project_name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.this.id 
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name     = "${var.project_name}-public-${var.azs[count.index]}"
    Project  = var.project_name
    Tier     = "public"
  }
}

resource "aws_subnet" "private" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.this.id 
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name     = "${var.project_name}-private-${var.azs[count.index]}"
    Project  = var.project_name
    Tier     = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id       = aws_vpc.this.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name     = "${var.project_name}-public-rt"
    Project  = var.project_name
  }

}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.public.id
}
resource "aws_eip" "nat" {
    count = length(var.public_subnet_cidrs)

    domain = "vpc"
    tags = {
        Name = "${var.project_name}-nat-eip-${count.index + 1}"
    }
}
resource "aws_nat_gateway" "this" {
    count = length(var.public_subnet_cidrs)

    allocation_id = aws_eip.nat[count.index].id
    subnet_id     = aws_subnet.public[count.index].id

    tags = {
        Name = "${var.project_name}-nat-gw-${count.index + 1}"
    }
    depends_on = [ aws_internet_gateway.igw ]
}

