resource "aws_eip" "nat" {
  count = var.enable_nat_gateway && var.nat_gateway_eip_id == "" ? 1 : 0

  vpc = true

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}
resource "aws_nat_gateway" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = var.nat_gateway_eip_id != "" ? var.nat_gateway_eip_id : aws_eip.nat[0].id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }
}
