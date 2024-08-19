locals {
  default_tags = {
    ProjectName = "Amazon S3 Filesystem for Amazon EKS Cluster"
  }

  region = "ap-southeast-2"

  # configuration for the Amzon VPC
  vpc = {
    name       = "${var.env}-eks-vpc"
    tenancy    = "default"
    cidr_block = "10.0.0.0/16"

    enable_dns_hostnames = true
    enable_dns_support   = true

    private_subnets = {
      "private-subnet-1" = {
        availability_zone = "ap-southeast-2a"
        cidr_block        = "10.0.0.0/24"
      }

      "private-subnet-2" = {
        availability_zone = "ap-southeast-2b"
        cidr_block        = "10.0.1.0/24"
      }

      "private-subnet-3" = {
        availability_zone = "ap-southeast-2c"
        cidr_block        = "10.0.2.0/24"
      }
    }

    public_subnets = {
      "public-subnet-1" = {
        availability_zone = "ap-southeast-2a"
        cidr_block        = "10.0.10.0/24"
      }

      "public-subnet-2" = {
        availability_zone = "ap-southeast-2b"
        cidr_block        = "10.0.11.0/24"
      }

      "public-subnet-3" = {
        availability_zone = "ap-southeast-2c"
        cidr_block        = "10.0.12.0/24"
      }
    }
  }

  # configuration for the Amazon EKS cluster
  eks = {
    cluster_name    = "${var.env}-eks-cluster"
    cluster_version = "1.29"
    vpc_config = {
      subnet_ids = module.vpc.private_subnets

      # restrict access to the EKS API server to just the NAT Gateway Elastic IP (so that the nodes can connect to it)
      # and to our current public IP address
      public_access_cidrs = [
        "${data.http.my_external_ip.response_body}/32",
        "${module.vpc.nat_gw_eip}/32"
      ]
    }

    node_group = {
      subnet_ids     = toset(module.vpc.private_subnets)
      capacity_type  = "SPOT" # use spot instances to save money
      instance_types = ["t3.small"]
      desired_size   = 1
      min_size       = 0
      max_size       = 2
    }

    cluster_admin_access = {
      username = "johndoe"
      userarn  = "arn:aws:iam::123456789012:user/johndoe"
    }

    s3_csi_bucket_name = "mys3bucket" # Amazon S3 bucket that will be available from within the Amazon EKS cluster
  }
}
