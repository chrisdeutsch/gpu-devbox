variable "my_ip" {
  type        = string
  description = "Your public IP address (CIDR notation, e.g. 1.2.3.4/32)."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the GPU devbox."
  default     = "g6.xlarge"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the gpu-devbox VPC."
  default     = "10.42.0.0/24"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet in the gpu-devbox VPC."
  default     = "10.42.0.0/24"
}
