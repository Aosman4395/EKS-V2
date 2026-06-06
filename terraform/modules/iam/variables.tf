variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "eks-cluster"
}

variable "hosted_zone_id" {
  type = string
  default = "Z03631591EWPFVYXB2928"
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "namespace" {
  type    = string
  default = "external-dns"
}

variable "service_account_name" {
  type    = string
  default = "external-dns"
}