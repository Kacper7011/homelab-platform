resource "cloudflare_zero_trust_tunnel_cloudflared" "homelab_tunnel" {
  account_id = var.cloudflare_account_id
  name = "homelab_tunnel"
  secret = var.cloudflare_tunnel_secret
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "homelab_tunnel_config" {
  account_id = var.cloudflare_account_id
  tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.id

  config {
    dynamic ingress_rule {
      for_each = local.tunnel_hostnames

      content {
        hostname = "${ingress_rule.value}.${var.domain_name}"
        service = "http://traefik.kube-system.svc.cluster.local:80"
      }
    }

    ingress_rule {
      service = "http_status:404"
    }
  }
}
