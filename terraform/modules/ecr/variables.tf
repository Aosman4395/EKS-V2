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