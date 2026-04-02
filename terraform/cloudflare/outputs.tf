output "tunnel_token" {
  value = cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.tunnel_token
  sensitive = true
}