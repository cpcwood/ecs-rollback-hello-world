variable "vpc_name" {
  description = "namespace used for VPC and subnets"
}

variable "vpc_cidr_block" {
  description = "vpc CIDR block"
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "list of CIDRs for public subnets"
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "subnet_availability_zones" {
  description = "list of availability zones for subnets"
  default = ["eu-west-2a", "eu-west-2b"]
}
