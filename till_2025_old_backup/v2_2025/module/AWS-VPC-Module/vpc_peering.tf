resource "aws_vpc_peering_connection" "peer" {
  count = var.enable_vpc_peering ? 1 : 0  # Create only if enable_vpc_peering is true

  peer_vpc_id = var.peer_vpc_id
  vpc_id      = aws_vpc.main.id
  auto_accept = true

  tags = {
    Name = "${var.project_name}-vpc-peering"
  }
}
