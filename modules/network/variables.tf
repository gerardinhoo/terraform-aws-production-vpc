variable "name" {}

variable "vpc_cidr" {}

variable "public_subnets" {
  description = "Map of public subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  description = "Map of private subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {}
}

