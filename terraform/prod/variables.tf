variable "project_name" {
  type    = string
  default = "eks-v2"
}

variable "eks_cluster_name" {
  type    = string
  default = "eks-v2"
}

variable "kubernetes_version" {
  type    = string
  default = "1.33"
}

variable "vpc_name" {
  type    = string
  default = "eks-v2-vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "ecr_repositories" {
  type = list(string)

  default = [
    "api-gateway",
    "dashboard-api",
    "order-service",
    "payment-service",
    "shipping-service",
    "inventory-service",
    "notification-service",
    "analytics-service",
    "frontend"
  ]
}

variable "hosted_zone_id" {
  type    = string
  default = "Z03631591EWPFVYXB2928"
}

variable "principal_arn" {
  description = "The ARN of the OIDC provider for IRSA"
  type        = string
  default     = "arn:aws:iam::409987738946:root"
}