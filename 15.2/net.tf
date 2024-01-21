####----------------------------
#### Create vpc ####
####----------------------------

resource "yandex_vpc_network" "vpc" {
  description = "Create network"
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "subnets" {
  name           = "subnet-my"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = ["192.168.200.0/24"]
}
