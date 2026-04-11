locals {
    services = [
        "seafile",
        "homepage",
        "cloudflared",
        "adguard_home_sync",
        "grafana"
    ]

    services_env =  {
        seafile = var.seafile_env
        homepage = var.homepage_env
        cloudflared = var.cloudflared_env
        adguard_home_sync = var.adguard_home_sync_env
        grafana = var.grafana_env
    }
}