output "region"       { value = "${var.region}"       }
output "project_name" { value = "${var.project_name}" }
output "eks_kubeconfig" { value = "${module.eks.kubeconfig}" }
output "config_map_aws_auth" { value = "${module.eks.config_map_aws_auth}" }
