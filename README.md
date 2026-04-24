# gpu-devbox

Terraform configuration for spinning up a GPU instance on AWS.

## What it creates

- A `g6.xlarge` GPU instance (NVIDIA L4, 24GB) in `eu-central-1` using the AWS Deep Learning Base GPU AMI (Ubuntu 24.04)
- A security group allowing SSH from your IP only
- A cloud-init config that:
  - Creates a `chris` user with passwordless sudo and your SSH key
  - Installs `nvtop` and upgrades packages on first boot
  - Adds `/opt/bin` to `PATH`

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) ~> 1.11
- AWS CLI with the `personal` profile configured (SSO login: `aws sso login --profile personal`)

## Usage

1. Clone the repo and initialize Terraform:

   ```sh
   git clone https://github.com/chrisdeutsch0/gpu-devbox
   cd gpu-devbox
   terraform init
   ```

2. Create a `terraform.tfvars` file with your public IP:

   ```hcl
   my_ip = "1.2.3.4/32"
   ```

3. Apply:

   ```sh
   terraform apply
   ```

4. SSH in:

   ```sh
   ssh chris@$(terraform output -raw public_ip)
   ```

## Stopping the instance

To stop billing on compute (EBS storage still accrues), stop the instance:

```sh
aws ec2 stop-instances --profile personal --instance-ids <id>
```

To destroy all resources:

```sh
terraform destroy
```
