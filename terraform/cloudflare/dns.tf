resource "cloudflare_record" "navidrome" {
    for_each = toset(local.tunnel_hostnames)


    zone_id = var.cloudflare_zone_id
    name = each.key
    type = "CNAME"
    content = "${cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.id}.cfargotunnel.com"
    proxied = true
    ttl = 1
}