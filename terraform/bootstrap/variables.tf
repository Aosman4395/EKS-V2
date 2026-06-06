variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-2"
}

variable "s3_name" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string
  default     = "ahamed-eks-project-s3"
}

variable "ecr_name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "ahamed-eks-project-ecr"
}
