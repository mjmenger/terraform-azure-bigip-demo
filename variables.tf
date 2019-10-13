variable "prefix" {
  default = "tf-azure-bigip"
}

variable "cidr" {
  default = "10.0.0.0/16"
}

variable "region" {
  default = "westus"
}

variable "environment" {
  default = "demo"
}

variable "azs" {
  default = ["us-east-2a", "us-east-2b"]
}