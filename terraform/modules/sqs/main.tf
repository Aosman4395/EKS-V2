resource "aws_sqs_queue" "dlq" {
  name = "${var.project_name}-dlq"

  message_retention_seconds = 1209600

  sqs_managed_sse_enabled   = true
}

resource "aws_sqs_queue" "main" {
  name = "${var.project_name}-queue"

  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600

  sqs_managed_sse_enabled   = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })
}