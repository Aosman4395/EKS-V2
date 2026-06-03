# Service Architecture

This platform consists of nine Go microservices deployed to Amazon EKS.

## Service Overview

| Service | Port | Purpose |
|----------|------|----------|
| api-gateway | 8080 | Authentication, JWT handling, rate limiting and request routing |
| order-service | 8081 | Order lifecycle management and event publishing |
| inventory-service | 8082 | Inventory tracking and stock reservations |
| payment-service | 8083 | Payment processing and ledger management |
| notification-service | 8084 | Email and SMS notifications |
| shipping-service | 8085 | Shipment creation and tracking |
| dashboard-api | 8086 | Administrative dashboard and reporting |
| worker | 8090 (health) | Consumes SQS events and orchestrates asynchronous workflows |
| scheduler | 8091 (health) | Scheduled background jobs and maintenance tasks |

---

# API Gateway

## Purpose

The API Gateway is the public entry point for customer traffic.

Responsibilities:

- User registration and authentication
- JWT generation and validation
- Rate limiting
- Request routing to internal services

## Dependencies

- Redis
- Order Service
- Inventory Service
- Payment Service
- Notification Service
- Shipping Service

## EKS Considerations

- Publicly exposed through Ingress
- TLS managed by cert-manager
- JWT secrets sourced from AWS Secrets Manager
- Candidate for Horizontal Pod Autoscaling (HPA)

---

# Order Service

## Purpose

Owns the order lifecycle and publishes events whenever order state changes.

State flow:

```text
Pending
  ↓
Confirmed
  ↓
Processing
  ↓
Shipped
  ↓
Delivered
```

## Dependencies

- PostgreSQL
- Amazon SQS

## EKS Considerations

- Database migrations should be moved to Kubernetes Jobs
- Requires IRSA to publish to SQS
- Connection pool sizing must be controlled

---

# Inventory Service

## Purpose

Tracks stock levels and reservations.

## Dependencies

- PostgreSQL

## EKS Considerations

- Reservation race conditions
- Row-level locking requirements
- Migration handling
- Read-heavy workload

---

# Payment Service

## Purpose

Processes payments and maintains the payment ledger.

## Dependencies

- PostgreSQL
- Amazon SQS

## EKS Considerations

- Strictest IAM permissions
- Transactional database operations
- IRSA access limited to required queues

---

# Notification Service

## Purpose

Handles email and SMS notifications.

## Dependencies

- PostgreSQL
- SMTP Provider (future)
- SMS Provider (future)

## EKS Considerations

- External connectivity requirements
- Secrets managed through AWS Secrets Manager
- NAT Gateway or VPC Endpoint considerations

---

# Shipping Service

## Purpose

Creates and tracks shipments.

## Dependencies

- PostgreSQL
- Amazon SQS
- Carrier APIs

## EKS Considerations

- Public webhook endpoint
- Idempotent processing
- Webhook security controls

---

# Scheduler

## Purpose

Runs scheduled maintenance and background jobs.

Health endpoint:

```text
:8091
```

## Jobs

- Expire reservations
- Detect abandoned carts
- Retry failed payments
- Generate reports
- Cleanup events

## EKS Considerations

- Single replica only
- Candidate for Kubernetes CronJobs
- Deployment strategy should prevent duplicate execution

---

# Worker

## Purpose

Consumes SQS messages and coordinates asynchronous workflows.

Health endpoint:

```text
:8090
```

## Dependencies

- Amazon SQS
- Internal HTTP services

## EKS Considerations

- Scale using KEDA, not CPU
- Idempotent processing
- DLQ monitoring
- IRSA permissions for queue operations

---

# Dashboard API

## Purpose

Provides operational dashboards and reporting.

## Dependencies

- PostgreSQL

## EKS Considerations

- Public administrative access
- Read-heavy workload
- Embedded static assets via Go embed
- Separate hostname from customer-facing applications

---

# Event Flow

```text
order-service
      ↓
Amazon SQS
      ↓
worker
      ↓
inventory-service
payment-service
notification-service
shipping-service
```

# Core Platform Components

- Amazon EKS
- Amazon ECR
- Amazon SQS
- PostgreSQL StatefulSet
- Redis StatefulSet
- Argo CD
- Helm
- GitHub Actions
- Karpenter
- External Secrets
- cert-manager
- Prometheus
- Grafana