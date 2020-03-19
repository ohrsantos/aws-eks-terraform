# Security Groups  ********************************************************************************

resource "aws_security_group" "eks_nodes" {
  name        = "${var.nodes_defaults["name"]}-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
      "Name" = "${var.nodes_defaults["name"]}-sg"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
  
}

resource "aws_security_group" "eks_cluster" {
  name        = "${var.eks_cluster_name}-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
      "Name" = "${var.eks_cluster_name}-sg"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}



# Security Rules **********************************************************************************

data "http" "workstation_external_ip" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  workstation_external_cidr = "${chomp(data.http.workstation_external_ip.body)}/32"
}

# Node Rules

resource "aws_security_group_rule" "ingress_self" {
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "Allow node to communicate with each other"

  type                     = "ingress"
  source_security_group_id = aws_security_group.eks_nodes.id
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
}

resource "aws_security_group_rule" "ingress_cluster" {
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"

  type                     = "ingress"
  source_security_group_id = aws_security_group.eks_cluster.id
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "nlb_k8s_node" {
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow NLB to access Ingress"

  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 30000
  to_port           = 30000
  protocol          = "tcp"
}

# Master Rules

resource "aws_security_group_rule" "cluster_ingress_node_https" {
  security_group_id        = aws_security_group.eks_cluster.id
  description              = "Allow pods to communicate with the cluster API Server"

  type                     = "ingress"
  source_security_group_id = aws_security_group.eks_nodes.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "cluster_ingress_laptop_https" {
  security_group_id = aws_security_group.eks_cluster.id
  description       = "Allow laptop to communicate with the cluster API Server"

  type              = "ingress"
  cidr_blocks       = [local.workstation_external_cidr]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
}

resource "aws_security_group_rule" "cluster_ingress_laptop_all" {
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow laptop to communicate with all nodes"

  type              = "ingress"
  cidr_blocks       = [local.workstation_external_cidr]
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
}
