output "result" {
  description = "The resulting IPs including their subnet. This value can be directly used e.g. for creating a managed PostgreSQL cluster."
  value       = local.result_ips_cidr
}
