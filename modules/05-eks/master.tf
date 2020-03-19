resource "aws_eks_cluster" "eks_cluster" {
    name     = var.eks_cluster_name
    role_arn = aws_iam_role.eks_cluster.arn
  
    vpc_config {
        subnet_ids         = var.subnet_ids
        security_group_ids = [aws_security_group.eks_cluster.id]
    }
  
    depends_on = [
        aws_iam_role_policy_attachment.k8s_cluster_AmazonEKSClusterPolicy,
        aws_iam_role_policy_attachment.k8s_cluster_AmazonEKSServicePolicy,
    ]
}
