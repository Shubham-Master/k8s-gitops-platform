# Production-Ready Kubernetes Platform with GitOps (EKS + ArgoCD + Helm)

### A cloud-native, production-grade platform demonstrating GitOps automation, Kubernetes best practices, Infrastructure-as-Code, and full observability on AWS.

![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-AWS%20EKS-326CE5?logo=kubernetes)
![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-EF7B4D?logo=argo)
![Helm](https://img.shields.io/badge/Helm-Charts-0F1689?logo=helm)
![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazonaws)
![CI](https://github.com/Shubham-Master/k8s-gitops-platform/actions/workflows/deploy.yaml/badge.svg)

---

## Features

- **AWS EKS** cluster across 3 availability zones with managed node groups
- **GitOps automation** via ArgoCD — auto-sync, self-heal, drift detection, rollbacks
- **Helm charts** for each microservice with HPA, ALB ingress, health probes
- **4-module Terraform** — VPC, IAM, EKS, IRSA (no circular dependencies)
- **IRSA** (IAM Roles for Service Accounts) for ALB controller and cluster autoscaler
- **Observability stack** — Prometheus, Grafana, Loki (S3), Tempo (S3)
- **AWS ALB Ingress Controller** with HTTPS and path-based routing
- **CI/CD pipeline** via GitHub Actions — fmt check, validate, Helm lint, Docker build & push

---

## Architecture

```
                     ┌───────────────────────────────┐
                     │         GitHub Repo           │
                     │   (Helm + App Manifests)      │
                     └───────────────┬───────────────┘
                                     │ GitOps Pull
                                     ▼
                        ┌─────────────────────────┐
                        │        ArgoCD           │
                        │ (Sync, Drift, Rollback) │
                        └─────────┬───────────────┘
                                  │ Applies Helm Charts
                                  ▼
               ┌─────────────────────────────────────────────┐
               │        AWS EKS Cluster (us-east-1)          │
               │     3 AZs · Managed Node Group · IRSA       │
               └──────────────────┬──────────────────────────┘
                                  │
                    ┌─────────────┴──────────────┐
                    ▼                            ▼
         ┌──────────────────┐        ┌──────────────────────┐
         │   service-a      │        │     service-b        │
         │   (Helm + HPA)   │        │    (Helm + HPA)      │
         └────────┬─────────┘        └──────────┬───────────┘
                  └──────────┬────────────────────┘
                             ▼
                  ┌─────────────────────┐
                  │   AWS ALB Ingress   │
                  │  (HTTPS · internet) │
                  └─────────────────────┘
                             │
                             ▼
         ┌───────────────────────────────────────┐
         │  Observability (namespace: monitoring) │
         │  Prometheus · Grafana · Loki · Tempo   │
         └───────────────────────────────────────┘
```

---

## Project Structure

```
k8s-gitops-platform/
│
├── infra/terraform/
│   ├── main.tf               # Root module — wires vpc → iam → eks → irsa
│   ├── outputs.tf
│   ├── vpc/                  # VPC, subnets (public/private), NAT gateways
│   ├── iam/                  # EKS cluster role + node role
│   ├── eks/                  # EKS cluster, node group, OIDC provider
│   └── irsa/                 # IRSA roles for ALB controller + cluster autoscaler
│
├── argocd/
│   ├── bootstrap/
│   │   └── install-argocd.yaml   # ArgoCD namespace, config, ALB ingress
│   └── apps/
│       ├── service-a.yaml        # ArgoCD Application manifest
│       ├── service-b.yaml
│       └── observability.yaml
│
├── apps/
│   ├── service-a/
│   │   ├── Dockerfile
│   │   ├── cmd/main.go
│   │   ├── go.mod
│   │   └── helm/
│   │       ├── Chart.yaml
│   │       ├── values.yaml
│   │       └── templates/
│   │           ├── _helpers.tpl
│   │           ├── deployment.yaml
│   │           ├── service.yaml
│   │           ├── ingress.yaml
│   │           └── hpa.yaml
│   └── service-b/             # Same structure as service-a
│
├── observability/helm/        # kube-prometheus-stack + Loki + Tempo
│
└── .github/workflows/
    └── deploy.yaml            # CI: fmt → validate → helm lint → build & push
```

---

## Terraform Module Design

The 4 modules are wired in strict dependency order to avoid cycles:

```
module.vpc  ──────────────────────────────────────┐
                                                  ▼
module.iam  ──── (role ARNs) ──────────────► module.eks  ──── (OIDC) ──► module.irsa
```

| Module | Provisions |
|--------|-----------|
| `vpc`  | VPC, 3 public + 3 private subnets, NAT gateways, route tables |
| `iam`  | EKS cluster IAM role, node IAM role (no OIDC dependency) |
| `eks`  | EKS cluster, managed node group, OIDC provider |
| `irsa` | ALB controller IRSA role, cluster autoscaler IRSA role |

---

## Infrastructure Provisioning

### 1. Configure AWS credentials
```bash
aws configure
```

### 2. Deploy
```bash
cd infra/terraform
terraform init
terraform plan
terraform apply
```

### 3. Update kubeconfig
```bash
aws eks update-kubeconfig --region us-east-1 --name gitops-platform
```

### Tear down (to avoid costs)
```bash
terraform destroy
```

> EKS costs ~$0.10/hr for the control plane. Destroy when not in use.

---

## GitOps Bootstrap

### Install ArgoCD
```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f argocd/bootstrap/install-argocd.yaml
```

### Deploy all applications
```bash
kubectl apply -f argocd/apps/
```

ArgoCD auto-syncs from this repo. Every `git push` triggers a reconcile — no `kubectl apply` needed.

---

## Helm Chart Structure

Each service follows the same pattern:

```
apps/service-a/helm/
├── Chart.yaml
├── values.yaml          # image tag, replicas, ingress host, resources
└── templates/
    ├── _helpers.tpl
    ├── deployment.yaml  # topologySpreadConstraints for AZ spread
    ├── service.yaml
    ├── ingress.yaml     # AWS ALB annotations
    └── hpa.yaml         # CPU-based autoscaling
```

---

## Observability Stack

Deployed to the `monitoring` namespace via ArgoCD from `observability/helm/`.

| Tool | Purpose | Storage |
|------|---------|---------|
| Prometheus | Metrics scraping | EBS (gp3) |
| Grafana | Dashboards + alerting | EBS (gp3) |
| Loki | Log aggregation | S3 |
| Tempo | Distributed tracing | S3 |

Grafana is pre-configured with Loki and Tempo as data sources.

---

## CI/CD Pipeline

`.github/workflows/deploy.yaml` runs on every push to `main`:

```
Terraform fmt check
    │
Terraform validate (vpc / iam / eks)
    │
Helm lint (service-a / service-b / observability)
    │
Docker build & push to ECR  ← skipped if AWS secrets not configured
    │
GitOps tag bump → ArgoCD picks up new image automatically
```

---

## Requirements

| Tool | Version |
|------|---------|
| Terraform | >= 1.15 |
| kubectl | >= 1.29 |
| helm | >= 3.14 |
| AWS CLI | >= 2.0 |
| ArgoCD CLI | optional |

---

## Future Enhancements

- Argo Rollouts — canary / blue-green deployments
- Istio service mesh — mTLS, traffic management
- App-of-Apps pattern — multi-cluster GitOps
- Sealed Secrets — encrypted secrets in Git
- Cilium + Hubble — eBPF networking and observability
