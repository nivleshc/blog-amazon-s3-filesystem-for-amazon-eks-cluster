data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ssm_parameter" "bottlerocket_ami_version" {
  name = "/aws/service/bottlerocket/aws-k8s-${var.eks.cluster_version}/x86_64/latest/image_version"
}

data "aws_eks_addon_version" "s3_csi" {
  addon_name         = "aws-mountpoint-s3-csi-driver"
  kubernetes_version = var.eks.cluster_version
  most_recent        = true
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

data "tls_certificate" "eks_cluster" {
  url = local.oidc_url
}
