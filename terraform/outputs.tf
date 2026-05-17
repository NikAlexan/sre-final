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

