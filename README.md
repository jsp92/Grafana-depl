# Grafana Fargate Terraform Module

This Terraform module simplifies the deployment of Grafana on AWS Fargate, leveraging an Aurora RDS Postgres backend for seamless data storage.

## Setup

To ensure HTTPS enforcement, you must provide a DNS namespace, a Route53 zone ID, and a certificate ARN. Additionally, manually create two secret values for the database password and the Grafana admin password.

## Example Usage

```hcl
module "grafana" {
  source        = "../tf"
  dns_zone      = "Z0164055J9GRCYRUZIBL"
  region        = "us-east-1"
  vpc_id        = "vpc-0e9bf0e9d953d74a8"
  lb_subnets    = ["subnet-0c242337e09046a1c", "subnet-0613f61bb76f6cbd4"] # Public-Subnets
  subnets       = ["subnet-09837a31b0e860bff", "subnet-0f66b33675b8de57e"] # Private-Subnets
  db_subnet_ids = ["subnet-09837a31b0e860bff", "subnet-0f66b33675b8de57e"] # Private-Subnets
  cert_arn      = "arn:aws:acm:us-east-1:190388175788:certificate/70c34ae6-80de-4f13-bdcb-35d48c11692c"
  dns_name      = "jacksonpace.us"
  account_id    = "190388175788"
  grafana_count = 1
}
```

## Available Variables

- **aws_region:** Default is `us-east-1`
- **account_id:** (Required) The account to run the Grafana service
- **whitelist_ips:** Default is `0.0.0.0/0` (accessible by anyone). List of IP addresses that can access Grafana
- **dns_zone:** (Required) The Route53 zone ID used to create the DNS name
- **dns_name:** (Required) The DNS name for the Grafana service (e.g., `grafana.example.com`)
- **cert_arn:** (Required) The certificate ARN
- **vpc_id:** (Required) The VPC ID
- **subnets:** (Required) List of subnets
- **lb_subnets:** (Required) List of load balancer subnets
- **db_subnet_ids:** (Required) List of database subnet IDs
- **db_instance_type:** Default is `db.t3.medium`
- **image_url:** Default is `190388175788.dkr.ecr.us-east-1.amazonaws.com/grafana:latest`

## Build the Docker Image

1. Create a file named `Dockerfile` with the following content:

```Dockerfile
FROM grafana/grafana
USER root
RUN apk update; \
    apk --no-cache add curl;
USER grafana
HEALTHCHECK CMD curl -f http://127.0.0.1:3000/api/health || exit 1
ENTRYPOINT ["/run.sh"]
```

2. Build the Docker image:

```bash
docker build -t grafana:latest .
```

3. Push the Docker image to Amazon ECR:

   - Create an ECR repository:
     Go to the ECR Dashboard and create a new repository named `grafana`.

   - Authenticate Docker to ECR:
     Run the following command to authenticate Docker to your ECR registry:

     ```bash
     aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<your-region>.amazonaws.com
     ```

   - Tag and push the Docker image:

     ```bash
     docker tag grafana:latest <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/grafana:latest
     docker push <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/grafana:latest
     ```

### Run an AWS cli command to create the database password

aws ssm put-parameter --name "/grafana/GF_DATABASE_PASSWORD" --type "SecureString" --value "foo"

### Run an AWS cli command to create the Grafana password

aws ssm put-parameter --name "/grafana/GF_SECURITY_ADMIN_PASSWORD" --type "SecureString" --value "bar"
