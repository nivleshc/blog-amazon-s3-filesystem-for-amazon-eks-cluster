terraform {
  required_version = "~> 1.5.7"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.31.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.6"
    }
    http = {
      source  = "hashicorp/http"
      version = "~>3.4.3"
    }
  }
}

provider "aws" {
  region = local.region

  default_tags {
    tags = local.default_tags
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token # this needs to a data source and not a reference to the eks module
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.eks_cluster.token
  }
}
