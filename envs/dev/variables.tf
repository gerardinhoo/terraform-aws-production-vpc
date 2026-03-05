variable "region" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}
