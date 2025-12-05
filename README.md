# Production-Ready Kubernetes Platform with GitOps (EKS + ArgoCD + Helm)

A production-grade Kubernetes platform built on **AWS EKS** with **GitOps automation** using **ArgoCD** and **Helm**.  
This project demonstrates modern **Platform Engineering** practices including multi-environment isolation,  
declarative infrastructure provisioning with **Terraform**, automated deployments, and full observability  
using **Prometheus, Grafana, Loki, and Tempo**.

---

## 🚀 Features

- **AWS EKS-based Kubernetes Cluster**
- **GitOps automation** with ArgoCD (auto-sync, rollbacks, drift detection)
- **Helm charts** for consistent microservice deployments
- **Multi-environment setup**: `dev`, `stage`, `prod`
- **Fully automated IaC** using Terraform modules (VPC, EKS, IAM)
- **Observability stack**:
  - Prometheus (metrics)
  - Grafana (dashboards)
  - Loki (logs)
  - Tempo (tracing)
- **ALB Ingress Controller** for routing external traffic
- **Secure CI/CD** via GitHub Actions
- **Reusable, scalable platform** suitable for real-world production workloads

---

## 📌 Architecture Overview

```
                 ┌───────────────────────────────┐
                 │           GitHub Repo          │
                 │  (App + Helm + ArgoCD Config) │
                 └───────────────┬───────────────┘
                                 │ GitOps Pull
                                 ▼
                    ┌─────────────────────────┐
                    │        ArgoCD           │
                    │ (Auto-sync, Rollbacks)  │
                    └───────┬─────────────────┘
                            │ Applies Helm Charts
                            ▼
               ┌────────────────────────────────────┐
               │            AWS EKS Cluster          │
               │ dev / stage / prod namespaces       │
               └─────────────────┬───────────────────┘
                                 │
                                 ▼
     ┌─────────────────────────────────────────────────────────┐
     │   Microservices (Helm-based) + ALB Ingress Controller  │
     └─────────────────────────────────────────────────────────┘
                                 │
                                 ▼
       ┌─────────────────────────────────────────────────────┐
       │ Observability Stack (Prometheus, Grafana, Loki, Tempo) │
       └─────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
k8s-gitops-platform/
│
├── infra/
│   ├── terraform/
│   │   ├── vpc/
│   │   ├── eks/
│   │   ├── iam/
│   │   └── outputs.tf
│
├── argocd/
│   ├── bootstrap/
│   │   └── install-argocd.yaml
│   ├── apps/
│       ├── service-a.yaml
│       ├── service-b.yaml
│       ├── observability.yaml
│
├── apps/
│   ├── service-a/
│   │   └── helm/
│   ├── service-b/
│       └── helm/
│
└── README.md
```

---

## ⚙️ Infrastructure Provisioning (Terraform)

### **1. Configure AWS Credentials**
```bash
aws configure
```

### **2. Deploy Network + EKS + IAM**
```bash
cd infra/terraform
terraform init
terraform plan
terraform apply
```

Terraform provisions:

- VPC (private/public subnets)
- EKS cluster + node groups (or Fargate profiles)
- IAM roles for service accounts (IRSA)
- Security groups + cluster autoscaler permissions

---

## 🚀 ArgoCD Installation (Bootstrap)

Install ArgoCD into the `argocd` namespace:

```bash
kubectl create namespace argocd
kubectl apply -f argocd/bootstrap/install-argocd.yaml
```

Access ArgoCD UI:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

---

## 🎯 GitOps Application Deployment

Each microservice is deployed via ArgoCD `Application` manifests.

Example (`argocd/apps/service-a.yaml`):

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: service-a
spec:
  project: default
  source:
    repoURL: https://github.com/<your-username>/k8s-gitops-platform
    path: apps/service-a/helm
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## 📦 Deploy Microservices (Helm Charts)

### Helm chart structure:

```
apps/service-a/helm/
│── charts/
│── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│── values.yaml
```

ArgoCD will **automatically sync** changes from Git.

---

## 📊 Observability Stack

This platform includes:

- **Prometheus** → metrics and alerting  
- **Grafana** → dashboards  
- **Loki** → centralized logging  
- **Tempo** → distributed tracing  

All deployed via Helm and managed through ArgoCD.

---

## 🌐 Ingress (AWS ALB)

Microservices are exposed via ALB using:

```yaml
annotations:
  kubernetes.io/ingress.class: alb
```

Supports:

- HTTPS termination  
- Path-based routing  
- Multi-env routing via namespaces  

---

## 🧪 CI/CD (GitHub Actions)

Pipeline includes:

- Lint Helm charts  
- Validate Terraform  
- Build & push Docker images  
- Deploy via GitOps (ArgoCD auto-sync)  

Sample pipeline file:

```
.github/workflows/deploy.yaml
```

---

## 🛠️ Requirements

- AWS account  
- Terraform ≥ 1.4  
- kubectl  
- helm  
- ArgoCD CLI (optional)  
- Docker  

---

## 📈 Future Enhancements

- Service Mesh (Istio / Linkerd)
- Canary deployments with Argo Rollouts
- eBPF-based observability (Cilium + Hubble)
- Fargate migration for isolated workloads
- Multi-cluster GitOps with ArgoCD App-of-Apps pattern

---

## 🎉 Conclusion

This project represents a **complete, production-grade Kubernetes platform**, showcasing your skills in:

- Cloud architecture  
- Kubernetes  
- Platform Engineering  
- GitOps automation  
- Infrastructure as Code  
- Observability & monitoring  
- CI/CD best practices  

Perfect for interviews, portfolio, and real-world use.

---
