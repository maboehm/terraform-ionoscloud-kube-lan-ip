# get first server
data "ionoscloud_k8s_node_pool_nodes" "this" {
  k8s_cluster_id = var.k8s_cluster_id
  node_pool_id   = var.k8s_node_pool_id
}

data "ionoscloud_server" "first_node" {
  datacenter_id = var.datacenter_id
  id            = data.ionoscloud_k8s_node_pool_nodes.this.nodes[0].id
}

locals {
  # first IP of the NIC in the specified LAN
  private_ip = [for _, nic in data.ionoscloud_server.first_node.nics : nic.ips[0] if tostring(nic.lan) == var.lan_id][0]
  prefix     = format("%s%s", local.private_ip, var.subnet)

  result_ips = [
    for n in range(var.ip_number_start, var.ip_number_start + var.ip_number_count) : cidrhost(local.prefix, n)
  ]
  result_ips_cidr = [
    for ip in local.result_ips : format("%s%s", ip, var.subnet)
  ]
}
