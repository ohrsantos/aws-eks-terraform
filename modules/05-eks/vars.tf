variable "eks_cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "region" {
  type = string
}

variable "keypair_name" {
  type = string
}

variable "nodes_defaults" {
  type = map
}

variable "subnet_ids" {
  type = list
}
