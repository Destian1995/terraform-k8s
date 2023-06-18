provider "yandex" {
  token        = var.yandex_token
  folder_id    = var.yandex_folder_id
  cloud_id     = "ru-central1"
  zone         = "ru-central1-a"
}
resource "yandex_mdb_mongodb_cluster" "netology" {
  name = "netology"
  network_id = var.network_id
  subnet_ids = var.subnet_ids
  node_count = 3
  node {
    zone = "ru-central1-a"
    type = "mdb.mongodb.m1.small"
  }
  user {
    name = "example"
    password = "example"
  }
}

resource "yandex_mdb_mongodb_user" "netology" {
  name = "netology"
  password = "netology1"
  cluster_id = yandex_mdb_mongodb_cluster.example.id
  database_name = "admin"
  roles = [
    {
      database_name = "admin"
      role_name = "readWrite"
    }
  ]
}
