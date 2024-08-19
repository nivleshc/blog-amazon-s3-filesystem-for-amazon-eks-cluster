resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.eks.cluster_version

  vpc_config {
    subnet_ids         = var.eks.vpc_config.subnet_ids
    security_group_ids = length(var.eks.vpc_config.security_group_ids) > 0 ? var.eks.vpc_config.security_group_ids : null

    endpoint_private_access = var.eks.vpc_config.endpoint_private_access
    endpoint_public_access  = var.eks.vpc_config.endpoint_public_access

    public_access_cidrs = length(var.eks.vpc_config.public_access_cidrs) > 0 ? var.eks.vpc_config.public_access_cidrs : null
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = {
    Name = var.eks.cluster_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSVPCResourceController,
  ]
}

# by default, the principal that creates the eks cluster, gets cluster-admin access. 
# grant an additional principal cluster-admin permissions
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  # we need to always give permissions to the nodes to the EKS cluster, otherwise they won't be able to join
  # the cluster successfully
  data = try(var.eks.cluster_admin_access.userarn, null) == null ? ({
    mapRoles = yamlencode([{
      rolearn  = aws_iam_role.eks_cluster_node_group.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }])
    }) : ({
    mapRoles = yamlencode([{
      rolearn  = aws_iam_role.eks_cluster_node_group.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }])
    mapUsers = yamlencode([{
      userarn  = var.eks.cluster_admin_access.userarn
      username = var.eks.cluster_admin_access.username
      groups   = ["system:masters"]
    }])
  })

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.eks.cluster_name}-ng"
  node_role_arn   = aws_iam_role.eks_cluster_node_group.arn
  subnet_ids      = var.eks.node_group.subnet_ids
  capacity_type   = var.eks.node_group.capacity_type
  instance_types  = var.eks.node_group.instance_types
  ami_type        = "BOTTLEROCKET_x86_64"
  release_version = var.eks.node_group.release_version != null ? var.eks.node_group.release_version : data.aws_ssm_parameter.bottlerocket_ami_version.value

  scaling_config {
    desired_size = var.eks.node_group.desired_size
    min_size     = var.eks.node_group.min_size
    max_size     = var.eks.node_group.max_size

  }

  update_config {
    max_unavailable_percentage = var.eks.node_group.max_unavailable_percentage
  }

  lifecycle {
    ignore_changes = [
      release_version,
      scaling_config[0].desired_size
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_cluster_node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_cluster_node_group_AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    Name = "${var.eks.cluster_name}-node"
  }
}
