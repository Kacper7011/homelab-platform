# homepage
resource "vault_kv_secret_v2" "services_secrets" {
    for_each = toset(local.services)
    mount = vault_mount.kv.path
    name = "services/${each.value}"
    delete_all_versions = true
    data_json = jsonencode(local.services_env[each.value])
}