terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.73"
    }
  }
  required_version = "~> 1.11"
}

provider "scaleway" {}

resource "scaleway_instance_ip" "public_ip" {}

resource "scaleway_instance_security_group" "ssh" {
  name                    = "gpu-devbox-ssh"
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"

  inbound_rule {
    action   = "accept"
    port     = 22
    ip_range = var.my_ip
  }
}

resource "scaleway_instance_server" "main" {
  name              = "main"
  type              = "L4-1-24G"
  image             = "ubuntu_noble_gpu_os_13_nvidia"
  ip_id             = scaleway_instance_ip.public_ip.id
  security_group_id = scaleway_instance_security_group.ssh.id

  root_volume {
    size_in_gb = 150
  }

  user_data = {
    cloud-init = file("${path.module}/cloud-init.yaml")
  }
}
