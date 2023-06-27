# Terraform module for IPs in private IONOS Cloud Kubernetes LANs

This module is a small helper around the limitation that you cannot know which
IP Addresses are assigned via DHCP in an IONOS Cloud LAN. This is impractival
when some services, like managed PostgreSQL databases require you to specify an
IP. The [official
example](https://github.com/ionos-cloud/terraform-provider-ionoscloud/blob/98dbd4d84d61ea63159ba95ea61130cb598dfa3c/docs/resources/dbaas_pgsql_cluster.md#example-usage)
for PostgreSQL outlines an example that works when you have a server connected
to the LAN, but the required setup for Managed Kubernetes Nodepools is a bit
more complicated, so this module encapsulates this.

For an example, check out the sample [main.tf](./example/main.tf).
