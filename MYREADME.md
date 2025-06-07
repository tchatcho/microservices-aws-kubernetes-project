# Coworking Space Microservice – DevOps Deployment Guide

## Overview

This repository contains a microservice designed to provide business analytics for a coworking space. Built to run in a Kubernetes environment, the service leverages a microservices architecture with cloud-native deployment, CI/CD integration, and observability tooling.

This guide focuses on helping DevOps and backend engineers understand the build, deploy, and release pipeline, without walking through beginner-level command-line instructions.

---

## 🧰 Technologies & Tools Used

| Purpose | Tool |
|--------|------|
| Containerization | Docker |
| Container Orchestration | Kubernetes (EKS) |
| Continuous Integration | AWS CodeBuild |
| Artifact Storage | Amazon ECR |
| Monitoring & Logging | AWS CloudWatch (Container Insights) |
| Database | PostgreSQL deployed via K8s YAML |
| Secrets & Configs | Kubernetes Secrets & ConfigMaps |

---

## 📦 Application Structure

- **Analytics Microservice**: Python-based, exposes REST APIs for usage reporting.
- **Database**: PostgreSQL instance deployed inside the Kubernetes cluster, configured with PVCs.
- **CI/CD**: Docker image built using AWS CodeBuild and pushed to ECR. Kubernetes deployment is triggered manually or via GitOps.

---

## 🚀 Deployment Pipeline Summary

### 1. Dockerization & CI/CD Integration
- The application is containerized with a `Dockerfile` that sets up the Python environment, dependencies, and exposes the app.
- `buildspec.yaml` is used to automate:
  - Docker login using AWS CLI.
  - Building the image and tagging it with `$CODEBUILD_BUILD_NUMBER`.
  - Pushing the image to a private ECR repo.

> 🔁 Changes to `main` branch trigger a new CodeBuild build, resulting in a fresh image version pushed to ECR.

---

### 2. Kubernetes Deployment

- **Secrets** and **ConfigMaps** are used to externalize configuration, separating sensitive data (like DB credentials) from plaintext variables (like DB host and port).
- The deployment uses:
  - `livenessProbe` and `readinessProbe` for health monitoring.
  - `envFrom` for injecting config/environment variables.
  - `LoadBalancer` type service to expose the app publicly.

> 🔍 The deployment manifest references the latest ECR image tag (or latest digest) and is manually applied using `kubectl`.

---

### 3. Database Layer

- PostgreSQL is deployed with:
  - PersistentVolumeClaim for data durability.
  - Port-forwarding for local testing.
- Seed files are executed via `psql` to initialize schema and test data.
- The service is internal, with Kubernetes service abstraction allowing in-cluster DNS-based access.

---

## 🔁 Release Workflow

For experienced developers wishing to ship updates:

1. **Develop Locally**:
   - Test against forwarded Postgres using `psql` and curl on `127.0.0.1:5153`.

2. **Build and Push Image**:
   - Push to GitHub, triggering CodeBuild.
   - Validate image appears in ECR.

3. **Update K8s Deployment**:
   - Pull latest image version via tag or digest.
   - Apply changes: `kubectl apply -f deployment.yaml`.

4. **Verify & Test**:
   - Use `kubectl get svc` to obtain `EXTERNAL-IP`.
   - Test APIs with curl: `/api/reports/daily_usage` and `/api/reports/user_visits`.

5. **Monitor**:
   - Use AWS CloudWatch Container Insights for logs and metrics.
   - Set alerts if needed for unhealthy pods or degraded responses.

---

## 🔐 Security & Best Practices

- Use Kubernetes Secrets for sensitive values (e.g., `DB_PASSWORD`).
- Avoid storing plaintext secrets in Git.
- Use IAM roles for CodeBuild with least-privilege access to ECR.
- Rotate ECR image tags or use SHA digests for image immutability.
- Clean up unused clusters with `eksctl delete cluster` post-project.

---

## 🧪 Health Check Endpoints

- `GET /health_check`: For liveness.
- `GET /readiness_check`: For readiness probe.

These are leveraged by Kubernetes to determine pod health and availability.

---

## 📊 Monitoring & Logging

Enable **CloudWatch Container Insights**:
- Provides real-time CPU, memory, and disk usage metrics.
- Aggregates logs from the analytics service container.
- Can be configured for alerting and dashboarding in AWS Console.

---

## 💡 Notes for Advanced Use

- Consider Helm charts or Kustomize for more flexible deployments.
- Use GitOps (e.g., ArgoCD or Flux) for automated syncing of Kubernetes state from Git.
- Externalize DB with RDS in a production-grade setup and connect via Service name or environment override.

---

## 📚 References

- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [AWS CodeBuild Docs](https://docs.aws.amazon.com/codebuild/)
- [DockerHub Python Images](https://hub.docker.com/_/python)

