data "aws_availability_zones" "available" {}

resource "aws_subnet" "pub_subnet" {
    count             = var.subnet_count
    vpc_id            = aws_vpc.vpc.id

    availability_zone = data.aws_availability_zones.available.names[count.index]
    cidr_block        = cidrsubnet(var.vpc_cidr["main"], var.vpc_cidr["newbits"], count.index)
  
    tags = {
          "Name" = "${var.eks_cluster_name}-pub-subnet-${count.index}"
          "kubernetes.io/cluster/${var.eks_cluster_name}" =  "shared"
    }
    
}

resource "aws_subnet" "prv_subnet" {
    count             = var.subnet_count
    vpc_id            = aws_vpc.vpc.id

    availability_zone = data.aws_availability_zones.available.names[count.index]
    cidr_block        = cidrsubnet(var.vpc_cidr["main"], var.vpc_cidr["newbits"], count.index + var.subnet_count)
  
    tags = {
          "Name" = "${var.eks_cluster_name}-prv-subnet-${count.index}"
          "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    }
}
