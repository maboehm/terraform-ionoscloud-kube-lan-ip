terraform {
  required_version = ">=1.5.0"
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = ">=6.4.0"
    }
    local = {
      source  = "local"
      version = ">=2.4.0"
    }
  }
}

resource "ionoscloud_datacenter" "example" {
  name     = "ip-example"
  location = "de/fra"
}

resource "ionoscloud_lan" "example" {
  datacenter_id = ionoscloud_datacenter.example.id
  name          = "example-test"
}

resource "ionoscloud_k8s_cluster" "example" {
  name = "example-cluster"
}

resource "ionoscloud_k8s_node_pool" "example" {
  allow_replace  = true
  name           = "default-nodepool"
  k8s_cluster_id = ionoscloud_k8s_cluster.example.id
  k8s_version    = ionoscloud_k8s_cluster.example.k8s_version

  datacenter_id     = ionoscloud_datacenter.example.id
  availability_zone = "AUTO"
  cpu_family        = "INTEL_SKYLAKE"

  node_count   = 1
  cores_count  = 2
  ram_size     = 2048
  storage_size = 20
  storage_type = "HDD"

  lans {
    id   = ionoscloud_lan.example.id
    dhcp = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "ip" {
  source  = "maboehm/kube-lan-ip/ionoscloud"
  version = ">=0.1.0"

  datacenter_id    = ionoscloud_datacenter.example.id
  lan_id           = ionoscloud_lan.example.id
  k8s_cluster_id   = ionoscloud_k8s_cluster.example.id
  k8s_node_pool_id = ionoscloud_k8s_node_pool.example.id
}

resource "random_password" "example" {
  length  = 32
  special = false
}

resource "ionoscloud_pg_cluster" "example" {
  display_name         = "example-cluster"
  postgres_version     = 15
  synchronization_mode = "ASYNCHRONOUS"

  instances    = 1
  cores        = 2
  ram          = 2048
  storage_size = 10240
  storage_type = "HDD"

  location = ionoscloud_datacenter.example.location
  connections {
    datacenter_id = ionoscloud_datacenter.example.id
    lan_id        = ionoscloud_lan.example.id
    cidr          = module.ip.result_with_cidr[0]
  }

  credentials {
    username = "root"
    password = random_password.example.result
  }
}

output "pg_ip" {
  value = module.ip.result[0]
}

output "pg_password" {
  value     = random_password.example.result
  sensitive = true
}

data "ionoscloud_k8s_cluster" "example" {
  id = ionoscloud_k8s_cluster.example.id
}

resource "local_sensitive_file" "kubeconfig" {
  content              = data.ionoscloud_k8s_cluster.example.kube_config
  filename             = pathexpand("~/.kube/example-cluster.json")
  file_permission      = "0600"
  directory_permission = "0750"
}

output "kubeconfig_path" {
  value = local_sensitive_file.kubeconfig.filename
}
