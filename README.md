# gpu-devbox

Terraform configuration for spinning up a GPU instance on Scaleway.

## What it creates

- An L4-1-24G GPU instance (Ubuntu Noble GPU OS 13, Nvidia)
- A public IP
- A security group allowing SSH from your IP only
- A cloud-init config that:
  - Creates a `chris` user with passwordless sudo and your SSH key
  - Installs `nvtop` and upgrades packages on first boot
  - Adds `/opt/bin` to `PATH`

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) ~> 1.11
- [Scaleway CLI](https://github.com/scaleway/scaleway-cli) configured with your credentials

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

To stop billing, archive the instance via the Scaleway CLI (do not just `poweroff` from inside — that leaves it in standby and billing continues):

```sh
scw instance server stop <server-id> zone=fr-par-2
```

To destroy all resources:

```sh
terraform destroy
```
