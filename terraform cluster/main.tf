provider "yandex" {
  token        = var.yandex_token
  folder_id    = var.yandex_folder_id
  cloud_id     = "ru-central1"
  zone         = "ru-central1-a"
}
resource "yandex_msk_cluster" "netology" {
  name = "netology-cluster"
  description = "Netology MSK cluster"
  network_id = var.network_id
  subnet_ids = var.subnet_ids
  zone = "ru-central1-a"
  service_account_id = var.service_account_id
  version = "1.19.9"
  node_spec {
    count = 1
    role = "MASTER"
    resources {
      memory = 4
      cores = 2
    }
  }
}

resource "yandex_msk_node_group" "netology" {
  cluster_id = yandex_msk_cluster.example.id
  name = "netology-node-group"
  description = "Netology MSK node group"
  node_template {
    resources {
      memory = 4
      cores = 2
    }
  }
  scale_policy {
    fixed_scale {
      size = 4
    }
  }
}