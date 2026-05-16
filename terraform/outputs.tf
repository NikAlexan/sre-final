output "cluster_id" {
  description = "DOKS cluster ID."
  value       = digitalocean_kubernetes_cluster.main.id
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint."
  value       = digitalocean_kubernetes_cluster.main.endpoint
}

output "kubeconfig" {
  description = "Raw kubeconfig for kubectl. Write to ~/.kube/config or use KUBECONFIG env var."
  value       = digitalocean_kubernetes_cluster.main.kube_config[0].raw_config
  sensitive   = true
}

output "db_host" {
  description = "Private hostname of the managed PostgreSQL cluster."
  value       = digitalocean_database_cluster.postgres.private_host
}

output "db_port" {
  description = "PostgreSQL port."
  value       = digitalocean_database_cluster.postgres.port
}

output "db_user" {
  description = "Default database user."
  value       = digitalocean_database_cluster.postgres.user
}

output "db_password" {
  description = "Default database password."
  value       = digitalocean_database_cluster.postgres.password
  sensitive   = true
}

output "db_uri" {
  description = "Full PostgreSQL connection URI (private network)."
  value       = digitalocean_database_cluster.postgres.private_uri
  sensitive   = true
}
