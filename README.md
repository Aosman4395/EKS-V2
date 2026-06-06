## EKS Nine-Service Order Platform on Amazon EKS

## Contents

- [Summary](#summary)
- [Tech Stack](#tech-stack)
- [Nine Services](#nine-services)
- [Dockerfiles](#dockerfiles)
- [Terraform](#terraform)
- [CI/CD](#cicd)

## Summary

This project builds a production-style **Amazon EKS platform** for running a nine-service order application on Kubernetes.

The focus is on the platform work around the application: **Docker, Terraform, Kubernetes, CI/CD, GitOps, monitoring, storage and operational documentation**.

## Tech Stack

**AWS, EKS, ECR, Terraform, Docker, Kubernetes, GitHub Actions, Argo CD, Helm, PostgreSQL, Redis, Prometheus, Grafana, NGINX Ingress, cert-manager, ExternalDNS**

## Nine Services

| Service | Purpose |
|---|---|
| API Gateway | Entry point for requests and routes traffic to backend services. |
| Dashboard API | Provides data for dashboards and admin views. |
| Orders Service | Handles order creation and order management. |
| Products Service | Manages product catalogue data. |
| Customers Service | Manages customer information. |
| Payments Service | Handles payment-related logic. |
| Inventory Service | Tracks stock and inventory changes. |
| Notifications Service | Sends or manages service notifications. |
| Analytics Service | Processes reporting or analytics-related data. |

### Dockerfiles

Created Dockerfiles for each service so every application can be packaged as its own container image. This is needed because Kubernetes deploys containers, and each service must be built, versioned and deployed independently.

Implemented multi-stage Dockerfiles for each service, with smaller final images and non-root containers for a stronger security baseline.


### Terraform

Implemented the Terraform structure using bootstrap, reusable modules and separate environments.

Bootstrap handles remote state setup, modules keep the infrastructure reusable, and environments allow the same codebase to support different deployment stages.


### CI/CD

Created separate GitHub Actions pipelines for different parts of the platform, including service image builds, Terraform validation/deployment and smoke testing.

The workflows include AWS authentication, Docker image builds, ECR push preparation, Terraform format/validation checks, Trivy security scanning, workflow concurrency and manual approval gates.

This keeps application delivery, infrastructure changes and testing clearly separated while making deployments safer and easier to control.