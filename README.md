# gpu-devbox

OpenTofu configuration for spinning up a GPU instance on AWS.

## What it creates

- A `g6.xlarge` GPU instance (NVIDIA L4, 24GB) in `eu-central-1` using the AWS Deep Learning Base GPU AMI (Ubuntu 24.04)
- A dedicated VPC with a public subnet, internet gateway, and security group allowing SSH from your IP only
- A cloud-init config that:
  - Creates a `chris` user with passwordless sudo and your SSH key
  - Installs `nvtop` and upgrades packages on first boot
  - Adds `/opt/bin` to `PATH`

## Resource roles

- `aws_vpc.devbox`: Isolated network for the devbox resources.
- `aws_subnet.public`: Public subnet where the EC2 instance runs.
- `aws_internet_gateway.devbox`: Connects the VPC to the public internet.
- `aws_route_table.public`: Sends outbound internet traffic from the public subnet through the internet gateway.
- `aws_route_table_association.public`: Attaches the public route table to the public subnet.
- `aws_security_group.ssh`: Allows SSH from `my_ip` and allows outbound traffic.
- `aws_instance.devbox`: GPU EC2 instance configured by `cloud-init.yaml`.

## Prerequisites

- [OpenTofu](https://opentofu.org/docs/intro/install/) ~> 1.11
- AWS CLI with the `personal` profile configured (SSO login: `aws sso login --profile personal`)

## Usage

1. Clone the repo and initialize OpenTofu:

   ```sh
   git clone https://github.com/chrisdeutsch0/gpu-devbox
   cd gpu-devbox
   tofu init
   ```

2. Create a `terraform.tfvars` file with your public IP:

   ```hcl
   my_ip = "1.2.3.4/32"
   ```

   The managed VPC and public subnet both default to `10.42.0.0/24`. Override `vpc_cidr` or `public_subnet_cidr` if that range conflicts with your network.

3. Apply:

   ```sh
   tofu apply
   ```

4. SSH in:

   ```sh
   ssh chris@$(tofu output -raw public_ip)
   ```

## Stopping the instance

To stop billing on compute (EBS storage still accrues), stop the instance:

```sh
aws ec2 stop-instances --profile personal --instance-ids <id>
```

To destroy all resources:

```sh
tofu destroy
```
