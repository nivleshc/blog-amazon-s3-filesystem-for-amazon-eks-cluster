variable "vpc" {
  description = "VPC configuration details"
  type = object({
    name                 = string
    cidr_block           = string
    tenancy              = string
    enable_dns_hostnames = bool
    enable_dns_support   = bool

    private_subnets = map(object({
      cidr_block        = string
      availability_zone = string
    }))

    public_subnets = map(object({
      cidr_block        = string
      availability_zone = string
    }))
  })
}
