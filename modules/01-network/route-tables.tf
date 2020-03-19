resource "aws_route_table" "ngw_route_table" {
    count  = var.subnet_count
    vpc_id = aws_vpc.vpc.id
  
    route {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.ngw.*.id[count.index]
    }
  
    tags = {
      Name = "${var.eks_cluster_name}-nat-gateway-table-rt-${count.index}"
    }
}

resource "aws_route_table" "igw_route_table" {
     vpc_id = aws_vpc.vpc.id
   
     route {
         cidr_block = "0.0.0.0/0"
         gateway_id = aws_internet_gateway.igw.id
     }
   
     tags = {
         Name = "${var.eks_cluster_name}-igw-rt"
     }
}

resource "aws_route_table_association" "ngw_route_table_association" {
    count = var.subnet_count

    subnet_id      = aws_subnet.prv_subnet.*.id[count.index]
    route_table_id = aws_route_table.ngw_route_table.*.id[count.index]
}

resource "aws_route_table_association" "igw_route_table_association" {
    count = var.subnet_count

    subnet_id      = aws_subnet.pub_subnet.*.id[count.index]
    route_table_id = aws_route_table.igw_route_table.id
}
