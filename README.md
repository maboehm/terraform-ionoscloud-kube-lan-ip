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

For a full E2E example, check out the sample [main.tf](./example/main.tf).

After this is applied (takes about 30 minutes), you can do the following to
confirm the database can be reached from a pod:

**NOTE:** This exposes your password in the Pod spec, this is NOT recommended

```shell
export KUBECONFIG="$(terraform output -raw kubeconfig_path)"

kubectl run -i -t psql-test \
    --rm \
    --image=jbergknoff/postgresql-client \
    --env "PGPASSWORD=$(terraform output -raw pg_password)" \
    --command psql \
    -- -U root -h "$(terraform output -raw pg_ip)" postgres

# you should now have a psql shell open and can run e.g.
postgres=> \conninfo
You are connected to database "postgres" as user "root" on host "10.7.222.5" at port "5432".
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
```
