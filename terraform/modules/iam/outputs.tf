output "oidc_provider_url" {
  value = replace(
    aws_iam_openid_connect_provider.eks.url,
    "https://",
    ""
  )
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "external_dns_role_arn" {
  value = aws_iam_role.external_dns_role.arn
}

output "cert_manager_role_arn" {
  value = aws_iam_role.cert_manager_role.arn
}

output "ebs_csi_role_arn" {
  value = aws_iam_role.ebs_csi_role.arn
}

output "karpenter_controller_role_arn" {
  value = aws_iam_role.karpenter_controller_role.arn
}

output "karpenter_node_role_name" {
  value = aws_iam_role.karpenter_node_role.name
}

output "karpenter_node_instance_profile_name" {
  value = aws_iam_instance_profile.karpenter_node_instance_profile.name
}