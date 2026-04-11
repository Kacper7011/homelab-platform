ui = true

listener "tcp" {
	address = "0.0.0.0:8200"
	tls_disable = 1
}

storage "raft" {
	path = "/vault/data"
	node_id = "vault-node-01"
}

api_addr = "http://10.10.10.216:8200"
cluster_addr = "http://10.10.10.216:8201"

log_level = "info"
disable_mlock = true
