terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
   token  =  " "  < ЯНДЕКС АККАУНТ ТОКЕН >
   cloud_id  = " "
   folder_id = " "
  zone = "ru-central1-a"
}

variable "image-id" {
     type = string
 }



resource "yandex_compute_instance" "pervaya" {
     name = "terr-vm"
     platform_id = "standard-v2"
     zone = "ru-central1-a"
   
     resources {
      core_fraction = 5
      cores  = 2
      memory = 1
    }
 
     boot_disk {
         initialize_params {
             image_id = var.image-id
         }
    }
    
    network_interface {
       subnet_id = yandex_vpc_subnet.yc-public1.id
       nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/yandexFedora.pub")}"
  }

}

resource "yandex_vpc_network" "yc1" {
      name = "yc1"
}

resource "yandex_vpc_subnet" "yc-public1" {
  name           = "yc-public1"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.yc1.id}"
  v4_cidr_blocks = ["192.168.0.0/28"]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.pervaya.network_interface.0.ip_address
}
 
output "external_ip_address_vm_1" {
  value = yandex_compute_instance.pervaya.network_interface.0.nat_ip_address
}


# create cluster DB
resource "yandex_mdb_postgresql_cluster" "postgres-1" {
  name        = "postgres-1"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.yc1.id
 
  config {
    version = 12
    resources {
      resource_preset_id = "b2.medium"
      disk_type_id       = "network-hdd"
      disk_size          = 10
    }
    postgresql_config = {
      max_connections                   = 90
      enable_parallel_hash              = true
      vacuum_cleanup_index_scale_factor = 0.2
      autovacuum_vacuum_scale_factor    = 0.34
      default_transaction_isolation     = "TRANSACTION_ISOLATION_READ_COMMITTED"
      shared_preload_libraries          = "SHARED_PRELOAD_LIBRARIES_AUTO_EXPLAIN,SHARED_PRELOAD_LIBRARIES_PG_HINT_PLAN"
    }
  }
 
  database {
    name  = "postgres-1"
    owner = "my-name"
  }
 
  user {
    name       = "my-name"
    password   = "Test1234"
    conn_limit = 50
    permission {
      database_name = "postgres-1"
    }
    settings = {
      default_transaction_isolation = "read committed"
      log_min_duration_statement    = 5000
    }
  }
 
  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.yc-public1.id
  }
} 
