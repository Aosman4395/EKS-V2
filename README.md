# EKS Nine-Service Order Platform on Amazon EKS

## Contents

* [Summary](#summary)
* [Tech Stack](#tech-stack)
* [Nine Services](#nine-services)
* [Dockerfiles](#dockerfiles)
* [Terraform](#terraform)
* [CI/CD](#cicd)
* [Kubernetes Platform](#kubernetes-platform)

  * [Kubernetes Workloads](#kubernetes-workloads)
  * [Namespaces](#namespaces)
  * [Resource Management](#resource-management)
  * [Health Checks](#health-checks)
* [Stateful Workloads](#stateful-workloads)

  * [PostgreSQL StatefulSet](#postgresql-statefulset)
  * [Redis StatefulSet](#redis-statefulset)
  * [Persistent Storage](#persistent-storage)
* [GitOps](#gitops)

  * [Argo CD](#argo-cd)
  * [App-of-Apps](#app-of-apps)
  * [Helm](#helm)
* [Networking and Ingress](#networking-and-ingress)

  * [Traefik Ingress](#traefik-ingress)
  * [TLS and cert-manager](#tls-and-cert-manager)
  * [ExternalDNS](#externaldns)
* [Secrets Management](#secrets-management)

  * [HashiCorp Vault](#hashicorp-vault)
* [Event-Driven Architecture](#event-driven-architecture)

  * [Amazon SQS](#amazon-sqs)
  * [Dead Letter Queue](#dead-letter-queue)
* [Observability](#observability)

  * [Prometheus](#prometheus)
  * [Grafana](#grafana)
* [Kubernetes Security](#kubernetes-security)

  * [RBAC](#rbac)
  * [Network Policies](#network-policies)
  * [Container Security](#container-security)
* [Scaling and Availability](#scaling-and-availability)

  * [Horizontal Pod Autoscaling](#horizontal-pod-autoscaling)
  * [Pod Scheduling](#pod-scheduling)
  * [Topology Spread](#topology-spread)
  * [Karpenter](#karpenter)
* [AWS Storage Integration](#aws-storage-integration)

  * [EBS CSI](#ebs-csi)
  * [gp3 Storage](#gp3-storage)
* [AWS Production Deployment](#aws-production-deployment)

  * [Node Group Limitation](#node-group-limitation)
* [Moving the Platform to Kind](#moving-the-platform-to-kind)

  * [Why Kind](#why-kind)
  * [Kind Implementation Plan](#kind-implementation-plan)
  * [Replacing AWS-Specific Components](#replacing-aws-specific-components)
  * [Kafka Migration Plan](#kafka-migration-plan)
  * [What Will Remain the Same](#what-will-remain-the-same)
* [Current Project Status](#current-project-status)

---

## Summary

This project builds a production-style **Amazon EKS platform** for running a nine-service order application on Kubernetes.

The focus is on the platform engineering surrounding the applications, including:

* Infrastructure as Code.
* Containerisation.
* Kubernetes orchestration.
* CI/CD.
* GitOps.
* Persistent storage.
* Secrets management.
* Event-driven architecture.
* Ingress and TLS.
* Monitoring and observability.
* Kubernetes security.
* Scaling.
* High availability.
* Operational documentation.

The platform was initially designed and built for **Amazon EKS**, with AWS-native integrations used where appropriate.

After progressing through the AWS infrastructure and EKS deployment, an AWS account limitation was encountered while provisioning the worker node infrastructure.

The remaining Kubernetes platform work will therefore continue locally using **Kind**, while retaining the production architecture and replacing AWS-specific services with appropriate local alternatives.

---

## Tech Stack

**AWS, Amazon EKS, Amazon ECR, Amazon SQS, Terraform, Docker, Kubernetes, GitHub Actions, Argo CD, Helm, PostgreSQL, Redis, Prometheus, Grafana, Traefik, cert-manager, ExternalDNS, HashiCorp Vault**

Planned for the Kind phase:

**Kind, Apache Kafka**

---

# Application

## Nine Services

The platform contains nine independently deployable Go microservices.

| Service              | Purpose                                                          |
| -------------------- | ---------------------------------------------------------------- |
| API Gateway          | Entry point for requests and routes traffic to backend services. |
| Dashboard API        | Provides data for dashboards and administrative views.           |
| Inventory Service    | Tracks stock and inventory changes.                              |
| Notification Service | Handles application notifications.                               |
| Order Service        | Handles order creation and order management.                     |
| Payment Service      | Handles payment-related application logic.                       |
| Scheduler            | Runs scheduled and recurring background operations.              |
| Shipping Service     | Handles shipping and fulfilment workflows.                       |
| Worker               | Processes asynchronous background workloads.                     |

Each service has its own Go module and Dockerfile so it can be built, versioned, scanned and deployed independently.

---

## Dockerfiles

Created individual Dockerfiles for all nine services.

Multi-stage Docker builds are used to separate the application build process from the final runtime container.

The Docker configuration includes:

* Multi-stage builds.
* Smaller runtime images.
* Independent images for each service.
* Non-root container execution.
* Reduced runtime attack surface.
* Consistent build behaviour between environments.

This provides a stronger security baseline while keeping application images small and independently deployable.

---

# Infrastructure as Code

## Terraform

Implemented the AWS infrastructure using **Terraform** with reusable modules and environment separation.

The Terraform architecture includes:

* Bootstrap configuration.
* Remote Terraform state.
* Reusable modules.
* Environment-specific configuration.
* VPC networking.
* Public and private subnets.
* Route tables.
* Internet Gateway.
* NAT connectivity.
* Security groups.
* Amazon EKS.
* EKS managed node groups.
* IAM.
* ECR.
* Storage integration.
* SQS infrastructure.
* Supporting AWS resources.

The modular structure allows individual infrastructure components to be maintained independently while keeping the overall environment reproducible.

---

# CI/CD

## GitHub Actions

Created separate **GitHub Actions workflows** for application, infrastructure and validation tasks.

The pipelines include:

* Docker image builds.
* ECR image pushes.
* AWS authentication.
* Terraform formatting.
* Terraform validation.
* Terraform planning.
* Terraform deployment.
* Trivy vulnerability scanning.
* Smoke testing.
* Workflow concurrency.
* Manual approval gates.

Separating application delivery from infrastructure deployment reduces coupling between changes and makes the release process easier to control and troubleshoot.

---

# Kubernetes Platform

## Kubernetes Workloads

Created Kubernetes **Deployments and Services for all nine application services**.

The services communicate internally through Kubernetes networking rather than depending on fixed IP addresses.

The workload configuration includes:

* Deployments.
* ClusterIP Services.
* Replica configuration.
* Environment configuration.
* Resource management.
* Health probes.
* Security configuration.
* Service discovery.
* Pod scheduling controls.

---

## Namespaces

Platform components are separated logically using Kubernetes namespaces.

This helps separate:

* Application workloads.
* GitOps components.
* Monitoring.
* Ingress.
* Certificate management.
* Secrets management.
* Supporting infrastructure.

Namespace separation also provides a foundation for RBAC and NetworkPolicy controls.

---

## Resource Management

Added Kubernetes resource requests and limits to workloads.

Requests allow the Kubernetes scheduler to understand the resources required by a pod, while limits prevent individual workloads from consuming uncontrolled amounts of cluster resources.

Resources include:

* CPU requests.
* CPU limits.
* Memory requests.
* Memory limits.

These values also provide a foundation for autoscaling and capacity planning.

---

## Health Checks

Added Kubernetes health probes to application workloads.

These include:

* Liveness probes.
* Readiness probes.

Readiness probes prevent traffic from being sent to an application until it is ready to serve requests.

Liveness probes allow Kubernetes to identify and restart unhealthy application containers.

---

# Stateful Workloads

## PostgreSQL StatefulSet

Added **PostgreSQL as a Kubernetes StatefulSet**.

A StatefulSet is used rather than a standard Deployment because PostgreSQL requires stable storage and predictable stateful behaviour.

The PostgreSQL configuration includes:

* StatefulSet deployment.
* Stable pod identity.
* PersistentVolumeClaims.
* Persistent database storage.
* Kubernetes Service discovery.
* Resource requests and limits.
* Health checks.
* Secret-based database credentials.
* Persistent storage independent of pod lifecycle.

This allows PostgreSQL pods to be recreated without treating the database data itself as disposable.

---

## Redis StatefulSet

Added **Redis as a Kubernetes StatefulSet**.

The Redis implementation includes:

* PersistentVolumeClaims.
* Stable pod identity.
* Persistent storage.
* Kubernetes Service discovery.
* Resource configuration.
* Health checking.
* Redis persistence.
* AOF persistence.

AOF persistence provides greater durability by recording Redis write operations so state can be recovered following a restart.

---

## Persistent Storage

Added Kubernetes persistent storage configuration for stateful workloads.

This includes:

* PersistentVolumes.
* PersistentVolumeClaims.
* StorageClasses.
* StatefulSet volume claim templates.
* PostgreSQL persistent storage.
* Redis persistent storage.

This separates the lifecycle of application containers from the lifecycle of application data.

---

# GitOps

## Argo CD

Added **Argo CD** as the platform's GitOps controller.

Git acts as the source of truth for the desired Kubernetes state.

Rather than manually maintaining cluster resources, changes are committed to Git and reconciled into Kubernetes by Argo CD.

Argo CD configuration includes:

* Automated synchronisation.
* Self-healing.
* Automated pruning.
* Application health monitoring.
* Declarative deployment configuration.

---

## App-of-Apps

Implemented an **Argo CD App-of-Apps** structure.

A root Argo CD Application manages the child Applications required by the platform.

This allows the GitOps structure to manage components such as:

* Application workloads.
* Monitoring.
* Ingress.
* Certificate management.
* ExternalDNS.
* Supporting platform components.

The structure makes it possible to bootstrap a large portion of the Kubernetes platform from Git.

---

## Helm

Added **Helm** for configurable Kubernetes platform components.

Helm values are maintained through the GitOps repository so configuration remains version-controlled and reproducible.

This allows upstream Kubernetes applications to be installed without maintaining large amounts of duplicated YAML.

---

# Networking and Ingress

## Traefik Ingress

Added **Traefik** as the Kubernetes ingress controller.

Traefik provides a single ingress layer for incoming application traffic.

Instead of exposing every microservice individually, traffic enters through the ingress layer and is routed to the correct Kubernetes Service.

The general flow is:

**Client → Traefik → Kubernetes Service → Application Pod**

---

## TLS and cert-manager

Added **cert-manager** for Kubernetes TLS certificate management.

cert-manager provides:

* Declarative Certificate resources.
* Certificate issuance.
* Certificate renewal.
* TLS integration with ingress.
* Kubernetes-native certificate lifecycle management.

This removes the need to manually distribute and renew TLS certificates.

---

## ExternalDNS

Added **ExternalDNS** to the EKS architecture.

ExternalDNS allows DNS records to be created and updated automatically from Kubernetes resources.

In AWS, this can integrate Kubernetes ingress configuration with the AWS DNS infrastructure rather than requiring DNS records to be manually maintained.

---

# Secrets Management

## HashiCorp Vault

Added **HashiCorp Vault** to provide production-style secrets management.

Vault allows sensitive information to be managed separately from normal Kubernetes manifests and application source code.

Examples of secrets include:

* PostgreSQL credentials.
* Redis credentials.
* Application secrets.
* Service credentials.
* API credentials.
* Runtime tokens.

The goal is to prevent sensitive credentials from being hard-coded directly into source-controlled Kubernetes configuration.

Vault will remain part of the platform when development moves to Kind.

---

# Event-Driven Architecture

## Amazon SQS

Added **Amazon SQS** as the asynchronous messaging service for the AWS/EKS architecture.

SQS allows services to communicate asynchronously rather than requiring every operation to use synchronous HTTP communication.

The architecture supports:

* Message producers.
* Asynchronous message queues.
* Worker consumers.
* Retry behaviour.
* Decoupled application services.

A typical flow is:

**Application Service → Amazon SQS → Worker**

This allows background workloads to continue independently from the original request lifecycle.

---

## Dead Letter Queue

Added an **SQS Dead Letter Queue (DLQ)** for failed message processing.

Messages that repeatedly fail processing can be moved from the main SQS queue into the DLQ.

The general failure flow is:

**Producer → SQS → Consumer Failure → Retry → DLQ**

This prevents permanently failing messages from continuously cycling through the primary queue and provides a location where failed events can be investigated.

The SQS configuration includes redrive behaviour between the main queue and DLQ.

---

# Observability

## Prometheus

Added **Prometheus** for Kubernetes and application metrics collection.

Prometheus provides visibility into areas such as:

* Pod health.
* CPU utilisation.
* Memory utilisation.
* Workload availability.
* Kubernetes resources.
* Application metrics.
* Stateful workloads.

---

## Grafana

Added **Grafana** for metrics visualisation and operational dashboards.

Grafana consumes metrics collected through Prometheus and provides a visual operational view of the platform.

Together, Prometheus and Grafana provide the foundation for monitoring the health and behaviour of the Kubernetes environment.

---

# Kubernetes Security

## RBAC

Added **Kubernetes Role-Based Access Control (RBAC)** as part of the platform security model.

RBAC controls which identities and service accounts are permitted to interact with Kubernetes resources.

This follows the principle of granting workloads only the permissions they require.

---

## Network Policies

Added **Kubernetes NetworkPolicies** to control east-west traffic between workloads.

Rather than allowing unrestricted pod-to-pod communication, network access can be explicitly permitted between workloads that need to communicate.

The intended model follows:

**Default deny → Explicitly allow required communication**

This reduces unnecessary connectivity and limits the potential blast radius of a compromised workload.

---

## Container Security

Container and workload security controls include:

* Non-root containers.
* Multi-stage Docker builds.
* Reduced runtime images.
* Resource restrictions.
* Secret separation.
* Trivy vulnerability scanning.
* Kubernetes security contexts.
* Controlled network access.

Security is therefore applied across the CI/CD, container, Kubernetes and infrastructure layers.

---

# Scaling and Availability

## Horizontal Pod Autoscaling

Added **Horizontal Pod Autoscaler (HPA)** configuration for application workloads.

HPA allows Kubernetes to adjust application replica counts according to resource utilisation and workload demand.

This improves:

* Scalability.
* Resource efficiency.
* Application availability.
* Response to changing demand.

---

## Pod Scheduling

Added scheduling configuration to improve how replicas are distributed throughout the Kubernetes cluster.

The goal is to avoid unnecessary concentration of application replicas on the same underlying infrastructure.

---

## Topology Spread

Added **topology spread constraints** to improve workload distribution.

In an EKS production environment, topology-aware scheduling can help distribute replicas across nodes and Availability Zones.

This reduces the chance of a single infrastructure failure affecting every replica of an application.

---

## Karpenter

Included **Karpenter** in the production EKS architecture for dynamic Kubernetes compute provisioning.

Karpenter can respond to unscheduled workloads and provision suitable EC2 capacity based on their requirements.

This complements application-level HPA:

**HPA → More Pods Required → Insufficient Node Capacity → Karpenter → Additional EC2 Capacity**

This allows both application replicas and the underlying compute layer to respond dynamically to demand.

Karpenter is AWS-specific and will therefore not run inside the Kind environment.

---

# AWS Storage Integration

## EBS CSI

Added the **Amazon EBS CSI driver** to the EKS architecture.

The EBS CSI driver allows Kubernetes PersistentVolumeClaims to dynamically provision Amazon EBS storage.

This provides AWS-backed persistent storage for stateful applications such as PostgreSQL and Redis.

---

## gp3 Storage

Configured **gp3** as the production storage type for persistent workloads.

The production design includes:

* Encrypted EBS storage.
* PostgreSQL persistent storage.
* Redis persistent storage.
* Kubernetes StorageClass configuration.
* Dynamic volume provisioning.

The local Kind implementation will replace EBS-backed storage with local Kubernetes-compatible persistent storage.

---

# AWS Production Deployment

## Production Architecture

The AWS phase of the project was designed around a production-style EKS environment consisting of:

* AWS VPC.
* Multiple subnets.
* Internet Gateway.
* NAT connectivity.
* Amazon EKS.
* EKS managed node groups.
* Amazon ECR.
* Amazon EBS.
* EBS CSI.
* Amazon SQS.
* SQS Dead Letter Queue.
* IAM.
* Argo CD.
* Traefik.
* cert-manager.
* ExternalDNS.
* Vault.
* PostgreSQL.
* Redis.
* Prometheus.
* Grafana.
* HPA.
* Karpenter.
* Kubernetes security controls.

This allowed the project to progress through the infrastructure, containerisation, CI/CD and Kubernetes platform design required for a production-style AWS deployment.

---

## Node Group Limitation

During the production deployment phase, the project encountered an issue when attempting to provision the required **EKS managed node group**.

The AWS account being used for the project was a **Free Tier account**, and account-level limitations prevented the required worker node infrastructure from being successfully provisioned.

Without functioning worker nodes, the Kubernetes workloads required for the remaining stages of the project could not be fully deployed and tested on EKS.

The decision was therefore made not to reduce the scope of the project simply to work around the AWS account restriction.

Instead, the existing AWS infrastructure and Terraform work will remain as the representation of the intended production architecture, while the Kubernetes platform will now be completed locally.

---

# Moving the Platform to Kind

## Why Kind

The next stage of the project will use **Kind (Kubernetes in Docker)**.

Kind allows a real Kubernetes cluster to run locally using Docker containers as Kubernetes nodes.

The move to Kind is intended to remove the AWS account limitation while still allowing the remaining platform engineering work to be completed.

The objective is **not** to simplify the platform into a basic local development environment.

Instead, the Kind implementation will preserve the production Kubernetes architecture wherever technically appropriate.

---

## Kind Implementation Plan

The Kind environment will be built as a multi-component Kubernetes platform containing the same application and platform layers used throughout the project.

The planned environment includes:

* Kind Kubernetes cluster.
* Control-plane and worker nodes.
* All nine Go microservices.
* PostgreSQL StatefulSet.
* Redis StatefulSet.
* Persistent storage.
* Argo CD.
* App-of-Apps.
* Helm.
* Traefik.
* cert-manager.
* HashiCorp Vault.
* Apache Kafka.
* Prometheus.
* Grafana.
* Horizontal Pod Autoscaling.
* RBAC.
* NetworkPolicies.
* Resource requests and limits.
* Health probes.
* Pod scheduling controls.
* Topology spread constraints.

The existing GitOps structure will be adapted rather than replaced so Git remains the source of truth for the Kubernetes platform.

---

## Replacing AWS-Specific Components

AWS-specific infrastructure cannot run directly inside Kind.

Where this occurs, the AWS service will be replaced with a local technology that provides the same architectural purpose.

| AWS / EKS Architecture     | Kind Architecture                   | Purpose                         |
| -------------------------- | ----------------------------------- | ------------------------------- |
| Amazon EKS                 | Kind                                | Kubernetes control plane        |
| EKS Managed Node Groups    | Kind worker nodes                   | Kubernetes compute              |
| Amazon ECR                 | Local images / local registry       | Container image distribution    |
| Amazon EBS                 | Local persistent volumes            | Persistent storage              |
| EBS CSI                    | Kind-compatible storage             | Kubernetes storage provisioning |
| AWS IAM / IRSA             | Kubernetes RBAC and ServiceAccounts | Workload permissions            |
| ExternalDNS / AWS DNS      | Local DNS / host configuration      | Name resolution                 |
| AWS infrastructure ingress | Traefik                             | Application ingress             |
| Amazon SQS + DLQ           | Apache Kafka                        | Event-driven messaging          |
| Karpenter                  | Kind node configuration             | Compute capacity                |

These substitutions allow the architecture to remain conceptually similar while removing dependencies on AWS infrastructure.

---

## Kafka Migration Plan

The **AWS/EKS implementation used Amazon SQS with a Dead Letter Queue** for asynchronous application messaging.

When the platform moves to Kind, SQS will no longer be available as a native local Kubernetes service.

The plan is therefore to introduce **Apache Kafka** as the local event-driven messaging platform.

Kafka will allow the project to continue demonstrating:

* Asynchronous communication.
* Producers.
* Consumers.
* Event-driven services.
* Background workers.
* Message retention.
* Service decoupling.
* Failure handling.

The application architecture will therefore transition from:

**AWS/EKS:**

**Producer → Amazon SQS → Consumer**

to:

**Kind:**

**Producer → Kafka Topic → Consumer**

Kafka is not being presented as part of the completed AWS implementation. It is a deliberate architectural change for the upcoming Kind phase of the project.

This change will also provide an opportunity to demonstrate operating a distributed messaging platform directly on Kubernetes rather than consuming a fully managed AWS queue service.

---

## What Will Remain the Same

The move to Kind does not mean the platform will be redesigned from scratch.

The intention is to preserve the Kubernetes and platform engineering work wherever possible.

The following concepts will remain:

* Nine-service microservice architecture.
* Kubernetes Deployments.
* Kubernetes Services.
* PostgreSQL StatefulSet.
* Redis StatefulSet.
* PersistentVolumeClaims.
* GitOps.
* Argo CD.
* App-of-Apps.
* Helm.
* Traefik.
* cert-manager.
* Vault.
* Prometheus.
* Grafana.
* HPA.
* RBAC.
* NetworkPolicies.
* Health probes.
* Resource management.
* Scheduling controls.
* Topology-aware workload distribution.

The main changes will be around services that previously depended directly on AWS.

---

# Current Project Status

The project has completed a substantial portion of the original AWS and EKS architecture, including:

**Terraform → AWS Infrastructure → ECR → Docker → CI/CD → EKS Architecture → Kubernetes Manifests → Stateful Workloads → Persistent Storage → GitOps → Ingress → TLS → Secrets Management → SQS/DLQ → Observability → Security → Autoscaling → Scheduling and Availability**

During the production EKS deployment stage, the AWS Free Tier account limitation prevented the required managed node group from being successfully provisioned.

The AWS phase will therefore remain documented as the intended **production architecture**, while the next phase will move the Kubernetes platform to **Kind**.

The Kind phase will focus on completing and validating the remaining platform functionality locally while maintaining production-style Kubernetes practices.

AWS-specific components will be replaced only where necessary, including the planned replacement of **Amazon SQS/DLQ with Apache Kafka** for local event-driven messaging.

This README will be updated once the migration to Kind has been completed and the final local platform architecture has been deployed and validated.
