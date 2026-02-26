# Elastic IP
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "3tier-nat-eip"
  }
}

# NAT Gateway in first public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "3tier-nat-gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}
