provider "yandex" {
  service_account_key_file = "key.json"
  folder_id    = var.yandex_folder_id
  cloud_id     = "ru-central1"
  zone         = "ru-central1-a"
}

resource "yandex_compute_instance" "master" {
  name = "master"
  zone = "ru-central1-a"
  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32"
    }
  }
  network_interface {
    subnet_id = var.subnet_id
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
  resources {
    cores = 2
    memory = 4
  }
}

resource "yandex_compute_instance" "worker" {
  count = 4
  name = "worker-${count.index}"
  zone = "ru-central1-a"
  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32"
    }
  }
  network_interface {
    subnet_id = var.subnet_id
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
  resources {
    cores = 2
    memory = 4
  }
}

resource "yandex_vpc_network" "network" {
  name = "network"
}

resource "yandex_vpc_subnet" "subnet" {
  name = "subnet"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

output "master_ip" {
  value = yandex_compute_instance.master.network_interface.0.ip_address
}

output "worker_ips" {
  value = [for instance in yandex_compute_instance.worker: instance.network_interface.0.ip_address]
}
