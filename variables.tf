variable "datacenter_id" {
  type        = string
  description = "Datacenter of the LAN/Kubernetes nodepool. If omitted, an additional data source is created in order to fetch the ID."
}

variable "lan_id" {
  type        = string
  description = "LAN ID of which you want to determine the IP Range"
}

variable "k8s_cluster_id" {
  type        = string
  description = "ID of the kubernetes cluster."
}

variable "k8s_node_pool_id" {
  type        = string
  description = "ID of the kubernetes nodepool"
}

variable "subnet" {
  type        = string
  description = "Subnet that is used in that LAN. By default, IONOS Cloud DHCP uses a /24 network for a private LAN."
  default     = "/24"

  validation {
    condition     = length(regexall("^/([0-9]|[1-2][0-9]|3[0-2])$", var.subnet)) > 0
    error_message = "Must be a valid subnet, like '/24'."
  }
}

variable "ip_number_start" {
  type        = number
  default     = 5
  description = "Start of IPs in the subnetwork to return."

  validation {
    condition     = var.ip_number_start >= 1
    error_message = "Start value must be at least 1"
  }
}


variable "ip_number_count" {
  type        = number
  default     = 1
  description = "Number of IPs to return."

  validation {
    condition     = var.ip_number_count >= 1
    error_message = "Count must be greater than 0"
  }
}
