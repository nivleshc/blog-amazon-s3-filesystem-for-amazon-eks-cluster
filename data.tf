data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# we need to use a data source to get the Amazon EKS cluster authentication details. This ensures that
# the token we use is always up-to-date.
# A stale token will prevent the kubernetes and helm providers from accessing the Amazon EKS cluster.
data "aws_eks_cluster_auth" "eks_cluster" {
  name = local.eks.cluster_name
}

# this is used to get our current public ip address
data "http" "my_external_ip" {
  url = "https://api.ipify.org"
}
