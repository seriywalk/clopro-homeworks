####----------------------------
#### Calling the vpc module ####
####----------------------------

resource "yandex_vpc_network" "vpc" {
  description = "Create network"
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "subnets" {
  
  for_each = { for k,v in local.subnets : k => v }

  name           = each.value.subname
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = [each.value.cidr]
  route_table_id = each.value.nat-gw == true ? yandex_vpc_route_table.nat-gw.id : null
}

resource "yandex_compute_image" "nat-instance" {
  source_family = "nat-instance-ubuntu-2204"
}

resource "yandex_compute_instance" "vms" {

  for_each = { for k,v in var.custom_vms: k => v }

  name        = each.value.name
  hostname    = each.value.name
  zone        = var.yc_zone

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = each.value.nat == true ? yandex_compute_image.nat-instance.id : var.nat_image_id
      type     = "network-hdd"
      size     = 20
    }
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id  = each.value.nat == true ? lookup(zipmap(values(yandex_vpc_subnet.subnets)[*].name,values(yandex_vpc_subnet.subnets)[*].id),var.name_subnet_public) : lookup(zipmap(values(yandex_vpc_subnet.subnets)[*].name,values(yandex_vpc_subnet.subnets)[*].id),var.name_subnet_privat)
    ip_address = each.value.ip_address
    nat        = each.value.nat
    security_group_ids = [yandex_vpc_security_group.main_sg.id]
  }

  metadata = {
    serial-port-enable = 1
#    ssh-keys = var.ssh_key
    user-data = "${file("users.txt")}"
  }
}

resource "yandex_vpc_route_table" "nat-gw" {
  name       = "nat-instance-route"
  network_id = yandex_vpc_network.vpc.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = var.custom_vms[1].ip_address
  }
}
