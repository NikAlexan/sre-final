variable "do_token" {
  description = "DigitalOcean API token. Set via TF_VAR_do_token env var — never hardcode."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region slug."
  type        = string
  default     = "ams3"
}

variable "cluster_name" {
  description = "Name prefix used for all provisioned resources."
  type        = string
  default     = "sre-capstone"
}

variable "k8s_version" {
  description = "Kubernetes version slug (run `doctl kubernetes options versions` to list available)."
  type        = string
  default     = "1.31"
}

variable "node_size" {
  description = "Droplet size for Kubernetes worker nodes."
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "node_count" {
  description = "Number of worker nodes in the default node pool."
  type        = number
  default     = 2
}

variable "db_name" {
  description = "Name of the PostgreSQL database created inside the managed cluster."
  type        = string
  default     = "ecommerce"
}
