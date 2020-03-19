data "aws_caller_identity" "current" {}

locals {
  config-map-aws-auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks_nodes.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/kubectl
      username: build
      groups:
        - system:masters  
CONFIGMAPAWSAUTH
}

locals {
  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks_cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks_cluster.certificate_authority.0.data}
  name: ${var.eks_cluster_name}
contexts:
- context:
    cluster: ${var.eks_cluster_name}
    user: ${var.eks_cluster_name}
  name: ${var.eks_cluster_name}
current-context: ${var.eks_cluster_name}
kind: Config
preferences: {}
users:
- name: ${var.eks_cluster_name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - ${var.eks_cluster_name}
KUBECONFIG
}

output "config_map_aws_auth" {
  value = "${local.config-map-aws-auth}"
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}
