variable "maas_api_url" {
  description = "MAAS server base URL — provider appends /api/2.0/ itself, do NOT include it here"
  type        = string
  default     = "http://localhost:5240/MAAS"
}

variable "maas_api_key" {
  description = "MAAS API key (consumer_key:token_key:token_secret). Sourced from MAAS_API_KEY env var."
  type        = string
  sensitive   = true
  # No default — must be provided via TF_VAR_maas_api_key (set by the
  # convenience script `source ./env.sh`).
}
