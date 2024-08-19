variable "eks" {
  description = "EKS cluster configuration values"

  type = object({
    cluster_name    = string
    cluster_version = string
    vpc_config = object({
      subnet_ids              = list(string)
      endpoint_private_access = optional(string, null)
      endpoint_public_access  = optional(string, null)
      public_access_cidrs     = optional(list(string), [])
      security_group_ids      = optional(list(string), [])
    })
    node_group = object({
      subnet_ids                 = set(string)
      capacity_type              = optional(string)
      instance_types             = list(string)
      release_version            = optional(string)
      desired_size               = optional(number, 0)
      min_size                   = optional(number, 0)
      max_size                   = optional(number, 1)
      max_unavailable_percentage = optional(string, 33)
    })
    cluster_admin_access = optional(object({
      username = string
      userarn  = string
    }))
    s3_csi_bucket_name = string
  })
}
