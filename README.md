# SRE Capstone Project — Production Readiness Review

## Stack

| Layer | Technology |
|---|---|
| Cloud | DigitalOcean |
| IaC | Terraform >= 1.6 |
| Orchestration | Kubernetes (DOKS) |
| Database | PostgreSQL (in-cluster) |
| Region | ams3 |

---

## Step 1: Infrastructure as Code (IaC)

### Resources provisioned via Terraform

| Resource | Details |
|---|---|
| VPC | `sre-capstone-vpc`, CIDR `10.10.0.0/16` |
| DOKS Cluster | `sre-capstone`, 2 nodes × `s-1vcpu-2gb` |
| Remote State | DigitalOcean Spaces — `sre-capstone-tfstate` (ams3) |

PostgreSQL runs inside the Kubernetes cluster (not managed DB).

### Directory structure

```
terraform/
├── versions.tf              # Provider + S3 backend (DO Spaces)
├── main.tf                  # VPC, DOKS cluster
├── variables.tf             # Input variables
├── outputs.tf               # Cluster endpoint, kubeconfig
└── terraform.tfvars.example # Example values (no secrets)
```

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.6
- [doctl](https://docs.digitalocean.com/reference/doctl/how-to/install/) (optional, for kubeconfig)
- DigitalOcean account with:
  - Personal Access Token
  - Spaces bucket `sre-capstone-tfstate` in `ams3`
  - Spaces Access Key

### Usage

```bash
# 1. Set credentials (never commit these)
export TF_VAR_do_token="dop_v1_..."
export AWS_ACCESS_KEY_ID="<spaces_key_id>"
export AWS_SECRET_ACCESS_KEY="<spaces_secret>"

# 2. Initialize
cd terraform
terraform init

# 3. Preview
terraform plan

# 4. Apply
terraform apply

# 5. Get kubeconfig
terraform output -raw kubeconfig > ~/.kube/config
```

### Variables

| Variable | Default | Description |
|---|---|---|
| `do_token` | — | DigitalOcean API token (required) |
| `region` | `ams3` | DO region |
| `cluster_name` | `sre-capstone` | Name prefix for all resources |
| `k8s_version` | `1.31` | Kubernetes version prefix |
| `node_size` | `s-1vcpu-2gb` | Worker node Droplet size |
| `node_count` | `2` | Number of worker nodes |
| `db_name` | `ecommerce` | PostgreSQL database name |

---

## Steps (в разработке)

- [x] Step 1: Infrastructure as Code (Terraform + DOKS)
- [ ] Step 2: CI/CD Pipeline (GitHub Actions)
- [ ] Step 3: Observability (Prometheus + Grafana)
- [ ] Step 4: SRE Operations (SLOs, auto-scaling, load testing)
