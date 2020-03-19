data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.eks_cluster.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"]
}

data "aws_region" "current" {}

locals {
  eks_nodes_userdata = <<USERDATA
#!/bin/bash
set -o xtrace
#cd /opt
#sudo yum install -y perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https perl-Digest-SHA.x86_64 >> results.txt
#curl https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.2.zip -O >> results.txt
#unzip CloudWatchMonitoringScripts-1.2.2.zip && \
#rm CloudWatchMonitoringScripts-1.2.2.zip && \
#cd aws-scripts-mon >> results.txt
#crontab -l | { cat; echo "*/1 * * * * /opt/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --disk-space-util --disk-path=/ --swap-util --auto-scaling --from-cron"; } | crontab -
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks_cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks_cluster.certificate_authority.0.data}' '${var.eks_cluster_name}'
USERDATA
}

resource "aws_ebs_encryption_by_default" "ebs_encryption" {
  enabled = true
}

resource "aws_launch_configuration" "config" {
  associate_public_ip_address = var.nodes_defaults["public_ip"]
  iam_instance_profile        = aws_iam_instance_profile.eks_nodes.name
  image_id                    = data.aws_ami.eks_worker.id
  instance_type               = var.nodes_defaults["instance_type"]
  key_name                    = var.keypair_name
  name_prefix                 = "eks-config"
  security_groups             = [aws_security_group.eks_nodes.id]
  user_data_base64            = base64encode(local.eks_nodes_userdata)
  ebs_optimized               = var.nodes_defaults["ebs_optimized"]

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  desired_capacity     = var.nodes_defaults["asg_desired_capacity"]
  launch_configuration = aws_launch_configuration.config.id
  max_size             = var.nodes_defaults["asg_max_size"]
  min_size             = var.nodes_defaults["asg_min_size"]
  name                 = "${var.nodes_defaults["name"]}-asg}"
  enabled_metrics      = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]

  vpc_zone_identifier = var.subnet_ids

  tag {
    key                 = "Name"
    value               = "${var.eks_cluster_name}-${var.nodes_defaults["name"]}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.eks_cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.eks_cluster_name}"
    value               = ""
    propagate_at_launch = true
  }
}
