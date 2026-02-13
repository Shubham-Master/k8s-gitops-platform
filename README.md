# Production-Ready Kubernetes Platform with GitOps (EKS + ArgoCD + Helm)

### 🔧 A cloud-native, production-grade platform demonstrating GitOps automation, Kubernetes best practices, Infrastructure-as-Code, and full observability on AWS.

![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-AWS%20EKS-326CE5?logo=kubernetes)
![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-EF7B4D?logo=argo)
![Helm](https://img.shields.io/badge/Helm-Charts-0F1689?logo=helm)
![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazonaws)
![GitHub](https://img.shields.io/badge/Repo-github.com%2FShubham--Master-181717?logo=github)

---

## 🚀 Features

- **AWS EKS-based Kubernetes Cluster**
- **GitOps automation** with ArgoCD (auto-sync, rollbacks, drift detection)
- **Helm charts** for consistent microservice deployments
- **Multi-environment setup** → `dev`, `stage`, `prod`
- **Fully automated IaC** using Terraform modules (VPC, EKS, IAM)
- **Observability stack** including:
  - Prometheus (metrics)
  - Grafana (dashboards)
  - Loki (logs)
  - Tempo (traces)
- **AWS ALB Ingress Controller** for production-grade routing
- **Secure CI/CD pipelines** via GitHub Actions
- **Scalable and reusable platform-engineering blueprint**

---

## 📌 Architecture Overview

```
                     ┌───────────────────────────────┐
                     │           GitHub Repo         │
                     │   (Helm + App Manifests)      │
                     └───────────────┬───────────────┘
                                     │ GitOps Pull
                                     ▼
                        ┌─────────────────────────┐
                        │        ArgoCD           │
                        │ (Sync, Drift, Rollback) │
                        └─────────┬───────────────┘
                                  │ Applies Helm
                                  ▼
               ┌─────────────────────────────────────────────┐
               │           AWS EKS Cluster (dev/stage/prod)  │
               └──────────────────┬──────────────────────────┘
                                  │
                                  ▼
       ┌───────────────────────────────────────────────────────────┐
       │ Microservices (Helm) + AWS ALB Ingress Controller         │
       └───────────────────────────────────────────────────────────┘
                                  │
                                  ▼
            ┌────────────────────────────────────────────────┐
            │  Observability Stack (Prometheus, Grafana,     │
            │  Loki, Tempo)                                  │
            └────────────────────────────────────────────────┘
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

### **1. Configure AWS**
```bash
aws configure
```

### **2. Deploy VPC + EKS + IAM**
```bash
cd infra/terraform
terraform init
terraform plan
terraform apply
```

Terraform provisions:

- VPC networking (public/private subnets)
- EKS cluster + node groups (or Fargate)
- IAM roles & IRSA mappings
- Autoscaling + cluster autoscaler permissions

---

## 🎯 GitOps Application Deployment

Each microservice is deployed through an ArgoCD `Application` manifest.

### **Example (argocd/apps/service-a.yaml)**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: service-a
spec:
  project: default
  source:
    repoURL: https://github.com/Shubham-Master/k8s-gitops-platform
    path: apps/service-a/helm
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### Why this matters:
✔ GitOps auto-sync  
✔ Helm-based deployment  
✔ Namespace isolation  
✔ Self-healing + drift correction  
✔ Correct repo path  

---

## 📦 Helm Microservice Deployment

Structure:

```
apps/service-a/helm/
│── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│── values.yaml
```

Once pushed → ArgoCD auto-applies it.  
No kubectl needed.

---

## 📊 Observability Stack

Includes:

- **Prometheus** → metrics  
- **Grafana** → dashboards  
- **Loki** → log aggregation  
- **Tempo** → distributed tracing  

Deployed via ArgoCD → always in sync with Git state.

---

## 🌐 Ingress (AWS ALB)

Example in `ingress.yaml`:

```yaml
annotations:
  kubernetes.io/ingress.class: alb
  alb.ingress.kubernetes.io/scheme: internet-facing
```

Supports HTTPS, path routing, multi-service routing.

---

## 🧪 CI/CD Pipeline (GitHub Actions)

Pipeline includes:

- Validate Terraform
- Lint Helm charts
- Build & push Docker images
- GitOps-triggered deployment (ArgoCD auto-sync)

Workflow file:  
`.github/workflows/deploy.yaml`

---

## 🛠 Requirements

- AWS account  
- Terraform (>=1.4)  
- kubectl  
- helm  
- Docker  
- ArgoCD CLI (optional)

---

## 🚀 Future Enhancements

- Istio or Linkerd service mesh
- Argo Rollouts (canary/blue-green)
- Multi-cluster GitOps (App-of-Apps)
- Cilium + Hubble (eBPF networking + observability)
- Fargate profiles for isolated workloads

---

## 🎉 Conclusion

This project showcases your expertise in:

- AWS + Kubernetes  
- GitOps automation  
- Terraform IaC  
- Helm packaging  
- Monitoring & Observability  
- Platform Engineering at scale  


---
