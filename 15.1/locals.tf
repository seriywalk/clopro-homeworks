locals {
  subnets = [
    { subname = var.name_subnet_privat, cidr = "192.168.20.0/24", nat-gw = true },
    { subname = var.name_subnet_public, cidr = "192.168.10.0/24", nat-gw = false },
  ]
}
