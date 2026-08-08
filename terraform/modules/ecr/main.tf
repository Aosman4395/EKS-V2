resource "aws_ecr_repository" "this" {
  for_each = toset(var.ecr_repositories)

  name = each.value

    force_delete = true


  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "IMMUTABLE"

    encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = each.value
  }
}
