[![CI Validate](https://github.com/Pacman006/gcp-core-gke-platform/actions/workflows/ci-validate.yml/badge.svg)](https://github.com/Pacman006/gcp-core-gke-platform/actions/workflows/ci-validate.yml)

# GCP Core Landing Zone & Multi-Environment GKE Platform

**Platform Domain:** `plt-core` | **IaC:** Terraform (`~> 1.9`) | **Runtime:** Private GKE + ArgoCD | **Security:** Zero-Trust (Keyless OIDC, Private Nodes, Secret Manager CSI)

An automated, zero-trust **Google Cloud Platform (GCP) Landing Zone and Multi-Environment (`dev`/`prod`) GKE Platform**. Built to eliminate ClickOps, static JSON service account keys, and public worker node exposure while enforcing DevSecOps image scanning and FinOps cost controls.

---

## Core Tech Stack

| Layer | Tools & Services |
| :--- | :--- |
| **Cloud & Networking** | GCP Custom VPC, Private Subnets, Cloud Router, Cloud NAT |
| **Infrastructure as Code** | Terraform (`~> 1.9`), GCS Versioned Remote State, `tflint` |
| **Container & GitOps** | GKE (Private Cluster, Spot VMs in `dev`), Kustomize, ArgoCD, Helm |
| **Security & Identity** | Workload Identity Federation (GitHub OIDC), GKE Workload Identity, GCP Secret Manager + CSI Driver, Trivy |
| **Observability & SRE** | `kube-prometheus-stack` (Prometheus + Grafana), HPA, PDB, `metrics-server` |
| **Application Runtime** | Python 3.12 (Flask + Gunicorn), Multi-stage Non-Root Docker Build |

---

## Key Architecture Decisions (ADRs)

| ID | Decision | Rationale |
| :--- | :--- | :--- |
| **ADR-001** | **Private GKE Nodes + Cloud NAT** | Zero public IPs on worker nodes; outbound image pulls routed via Cloud NAT. |
| **ADR-002** | **Workload Identity Federation (OIDC)** | Eliminates long-lived static JSON Service Account keys in GitHub Secrets. |
| **ADR-003** | **Pull-Based GitOps (ArgoCD)** | Continuous drift reconciliation without granting CI direct cluster-admin credentials. |
| **ADR-004** | **Isolated State Files per Environment** | Separate `dev` and `prod` GCS state backends to minimize blast radius. |
