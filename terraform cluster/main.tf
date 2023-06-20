provider "yandex" {
  token = var.yandex_token
  folder_id    = var.yandex_folder_id
  cloud_id     = "ru-central1"
  zone         = "ru-central1-a"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "master" {
  name = "master"
  zone = "ru-central1-a"
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }
  network_interface {
    subnet_id = var.subnet_id
    nat       = true
    ipv6      = false
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
  resources {
    cores = 2
    memory = 4
  }
provisioner "remote-exec" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = yandex_compute_instance.master.network_interface.0.nat_ip_address
  }

  inline = [
    "sudo apt-get update",
    "sudo apt-get install -y --fix-missing git",
    "python3 -m pip install --user ansible-core==2.12.0",
    "sudo apt-get install -y containerd",
    "cat <<EOF | sudo tee /etc/containerd/config.toml",
    "[plugins]",
    "  [plugins.\"io.containerd.grpc.v1.cri\"]",
    "    [plugins.\"io.containerd.grpc.v1.cri\".containerd]",
    "      snapshotter = \"overlayfs\"",
    "      [plugins.\"io.containerd.grpc.v1.cri\".containerd.default_runtime]",
    "        runtime_type = \"io.containerd.runtime.v1.linux\"",
    "        runtime_engine = \"/usr/bin/runc\"",
    "        runtime_root = \"\"",
    "EOF",
    "sudo systemctl restart containerd"
  ]
 }
}

resource "yandex_compute_instance" "worker" {
  count = 4
  name = "worker-${count.index}"
  zone = "ru-central1-a"
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }
  network_interface {
    subnet_id = var.subnet_id
    nat       = true
    ipv6      = false
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
  resources {
    cores = 2
    memory = 2
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
