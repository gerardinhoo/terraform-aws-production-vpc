variable "region" {
  default = "us-east-1"
}

variable "bucket_name" {
  default = "gerard-terraform-state-2026"
}

variable "dynamodb_table" {
  default = "terraform-locks"
}
