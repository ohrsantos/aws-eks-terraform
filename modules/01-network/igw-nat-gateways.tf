resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
  
    tags = {
         Name = "${var.eks_cluster_name}-igw"
    }
}

resource "aws_eip" "ngw_eip" {
    count = var.subnet_count
    vpc   = true
    tags =  {
        Name = "${var.eks_cluster_name}-nat-gateway-eip-${count.index}"
    }
}

resource "aws_nat_gateway" "ngw" {
    count         = var.subnet_count
    allocation_id = aws_eip.ngw_eip.*.id[count.index]
    subnet_id     = aws_subnet.pub_subnet.*.id[count.index]
  
    tags = {
        Name = "${var.eks_cluster_name}-nat-gateway-${count.index}"
    }
  
    depends_on = [aws_internet_gateway.igw]
}
