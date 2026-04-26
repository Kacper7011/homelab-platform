locals {
    services = [
        "seafile",
        "homepage",
        "cloudflared",
        "adguard_home_sync",
        "grafana",
        "forgejo",
	    "rustfs",
    ]

    services_env =  {
        seafile = var.seafile_env
        homepage = var.homepage_env
        cloudflared = var.cloudflared_env
        adguard_home_sync = var.adguard_home_sync_env
        grafana = var.grafana_env
        forgejo = var.forgejo_env
	    rustfs = var.rustfs_env
    }
}

resource "vault_kv_secret_v2" "services_secrets" {
    for_each = toset(local.services)
    mount = vault_mount.kv.path
    name = "services/${each.value}"
    delete_all_versions = true
    data_json = jsonencode(local.services_env[each.value])
}
