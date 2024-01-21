//VM group
data "yandex_compute_image" "lamp" {
  family = "lamp"
}

// Instance group
resource "yandex_compute_instance_group" "ig" {
  name                = "ig-balancer"
  folder_id           = var.yc_folder_id
  service_account_id  = "${yandex_iam_service_account.sa_bucket.id}"
  deletion_protection = false
  instance_template {
    platform_id = "standard-v1"
    resources {
      memory = 2
      cores  = 2
      core_fraction = 20
    }

    boot_disk {
      #mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.lamp.id
        type     = "network-ssd"
      }
    }
    
     network_interface {
      network_id = yandex_vpc_network.vpc.id
      subnet_ids = [yandex_vpc_subnet.subnets.id]
      #nat        = true
    }

    scheduling_policy { preemptible = true }
    metadata = {
      serial-port-enable = 1
      ssh-keys = var.ssh_key
      user-data  = "#cloud-config\n runcmd:\n - cd /var/www/html\n - echo '<html><img src=\"http://${yandex_storage_bucket.bucket_net.bucket_domain_name}/${yandex_storage_object.image.key}\"/></html>' | sudo tee index.html\n - sudo systemctl restart apache2"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.yc_zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
    max_deleting    = 1
    max_creating    = 1
  }

  load_balancer {
    target_group_name        = "target-group"
    target_group_description = "load balancer target group"
  }
  depends_on = [yandex_storage_bucket.bucket_net]
}

## network Loadbalancer
resource "yandex_lb_network_load_balancer" "lb-1" {
  name = "network-load-balancer-1"

  listener {
    name = "network-load-balancer-1-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.ig.load_balancer.0.target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
  depends_on = [yandex_compute_instance_group.ig]
}
