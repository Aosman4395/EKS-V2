variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "eks-cluster"
}

variable "kubernetes_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets for the EKS cluster"
  type        = list(string)

}


variable "vpc_id" {
  description = "The ID of the VPC for the EKS cluster"
  type        = string
}

variable "principal_arn" {
  description = "The ARN of the OIDC provider for IRSA"
  type        = string
  default     = "arn:aws:iam::409987738946:root"
}