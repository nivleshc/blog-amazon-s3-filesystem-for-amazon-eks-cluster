# create a resource group. This will allow us to easily see all resources
# provisioned by this project using the AWS Management Console
resource "aws_resourcegroups_group" "project_resources" {
  name        = replace("${local.default_tags["ProjectName"]}-resources", " ", "-")
  description = "All resources provisioned for project ${local.default_tags["ProjectName"]}"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported" 
  ],
  "TagFilters": [
    {
      "Key": "ProjectName",
      "Values": ["${local.default_tags["ProjectName"]}"]
    }
  ]
}
JSON
  }

  tags = {
    Name = "${local.default_tags["ProjectName"]}-resources"
  }
}

# create a vpc, private subnets, public subnets, route tables, nat gateway
module "vpc" {
  source = "./vpc"

  vpc = local.vpc
}

# create an Amazon EKS cluster
module "eks" {
  source = "./eks"

  eks = local.eks

  depends_on = [
    module.vpc
  ]
}

# install kubernetes resources to demo Mountpoint for Amazon S3 CSI driver add-on
resource "helm_release" "s3-csi-demo" {
  name  = "s3-csi-demo"
  chart = "./helm/s3-csi-demo"

  depends_on = [
    module.eks
  ]
}
