module "network" {
    source           = "../modules/01-network"
  
    region           = var.region
    vpc_cidr         = var.vpc_block
    #vpc_cidr         = var.vpc_cidr
    eks_cluster_name = var.project_name
    subnet_count     = var.subnet_count
}

module "eks" {
    source           = "../modules/05-eks"
  
    region           = var.region
    keypair_name     = "${var.project_name}-${var.region}"
    eks_cluster_name = var.project_name
    nodes_defaults   = var.nodes_defaults
  
    subnet_ids       = module.network.subnet_ids
    vpc_id           = module.network.vpc_id
}
