# Terraform module for IPs in private IONOS Cloud Kubernetes LANs

This module is a small helper around the limitation that you cannot know which
IP Addresses are assigned via DHCP in an IONOS Cloud LAN. This is impractival
when some services, like managed PostgreSQL databases require you to specify an
IP. The [official
example](https://github.com/ionos-cloud/terraform-provider-ionoscloud/blob/98dbd4d84d61ea63159ba95ea61130cb598dfa3c/docs/resources/dbaas_pgsql_cluster.md#example-usage)
for PostgreSQL outlines an example that works when you have a server connected
to the LAN, but the required setup for Managed Kubernetes Nodepools is a bit
more complicated, so this module encapsulates this.

## Example

```hcl
module "ip" {
  source  = "maboehm/kube-lan-ip/ionoscloud"
  version = ">=0.1.0"

  datacenter_id    = ionoscloud_datacenter.example.id
  lan_id           = ionoscloud_lan.example.id
  k8s_cluster_id   = ionoscloud_k8s_cluster.example.id
  k8s_node_pool_id = ionoscloud_k8s_node_pool.example.id
}

resource "ionoscloud_pg_cluster" "example" {
  # incomplete config
  connections {
    datacenter_id = ionoscloud_datacenter.example.id
    lan_id        = ionoscloud_lan.example.id
    cidr          = module.ip.result_with_cidr[0]
  }
}
```

For a full E2E example, check out the sample [main.tf](./example/main.tf).

After this is applied (takes about 30 minutes), you can do the following to
confirm the database can be reached from a pod:

```shell
export KUBECONFIG="$(terraform output -raw kubeconfig_path)"

kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: pg-conntest
spec:
  containers:
  - name: postgresql-client
    image: jbergknoff/postgresql-client
    command: ["sleep", "infinity"]
    envFrom:
    - secretRef:
        name: pg-conntest
---
apiVersion: v1
kind: Secret
metadata:
  name: pg-conntest
stringData:
  PGHOST: $(terraform output -raw pg_ip)
  PGPASSWORD: $(terraform output -raw pg_password)
  PGDATABASE: postgres
  PGUSER: root
EOF

kubectl exec -it pg-conntest -- psql                                                                                                                    
psql (12.3, server 15.3 (Ubuntu 15.3-1.pgdg22.04+1))
WARNING: psql major version 12, server major version 15.
         Some psql features might not work.
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.

postgres=> 
```
