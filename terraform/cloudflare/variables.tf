variable "cloudflare_api_token" {
	description = "Cloudflare API token"
	type = string
	sensitive = true
}

variable "cloudflare_zone_id" {
	description = "Zone ID"
	type = string
}

variable "cloudflare_account_id" {
	description = "Cloudflare Account ID"
	type = string
}

variable "cloudflare_tunnel_secret" {
	description = "Cloudflare Tunnel Secret"
	type = string
	sensitive = true
}

variable "domain_name" {
	description = "Name of my public domain"
	type = string
}

