module "grafana" {
  source = "../tf"

  dns_zone      = "Z0164055J9GRCYRUZIBL"
  region        = "us-east-1"
  vpc_id        = "vpc-0e9bf0e9d953d74a8"
  lb_subnets    = ["subnet-0c242337e09046a1c", "subnet-0613f61bb76f6cbd4"]
  subnets       = ["subnet-09837a31b0e860bff", "subnet-0f66b33675b8de57e"]
  db_subnet_ids = ["subnet-09837a31b0e860bff", "subnet-0f66b33675b8de57e"]
  cert_arn      = "arn:aws:acm:us-east-1:190388175788:certificate/70c34ae6-80de-4f13-bdcb-35d48c11692c"
  dns_name      = "jacksonpace.us"
  account_id    = "190388175788"
  grafana_count = 1
}
