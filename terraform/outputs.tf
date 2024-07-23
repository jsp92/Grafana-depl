// lb dns
output "grafana_rds" {
  value = aws_rds_cluster.grafana.endpoint
}


