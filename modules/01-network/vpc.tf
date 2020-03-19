resource "aws_vpc" "vpc" {
    cidr_block           = var.vpc_cidr["main"]
    enable_dns_hostnames = "true"
    enable_dns_support   = "true"
  
    tags = {
          "Name"                                          = "${var.eks_cluster_name}-vpc"
          "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    }
}
