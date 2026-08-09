variable "maas_api_url" {
  description = "MAAS server base URL — provider appends /api/2.0/ itself, do NOT include it here"
  type        = string
  default     = "http://localhost:5240/MAAS"
}

variable "maas_api_key" {
  description = "MAAS API key (consumer_key:token_key:token_secret). Sourced from MAAS_API_KEY env var."
  type        = string
  sensitive   = true
}

# ── AWS ──────────────────────────────────────────────────────────────────────

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "eu-west-1"
}

# Credentials are provided via AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY env
# vars (standard AWS SDK convention) — no TF_VAR_ needed for those.

# ── Azure ────────────────────────────────────────────────────────────────────

variable "azure_subscription_id" {
  description = "Azure subscription ID."
  type        = string
  sensitive   = true
}

variable "azure_client_id" {
  description = "Azure service principal client ID."
  type        = string
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Azure service principal client secret."
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure Entra tenant ID (home tenant for the service principal)."
  type        = string
  sensitive   = true
}

variable "azure_resource_group" {
  description = "Azure resource group name for all minicloud resources."
  type        = string
  default     = "minicloud-platform-rg"
}

variable "azure_location" {
  description = "Azure region. West Europe = closest to SFR box (France)."
  type        = string
  default     = "West Europe"
}

# ── GCP ──────────────────────────────────────────────────────────────────────

variable "gcp_project_id" {
  description = "GCP project ID."
  type        = string
}

variable "gcp_region" {
  description = "GCP region. europe-west1 (Belgium) = closest to on-premise cluster."
  type        = string
  default     = "europe-west1"
}

# Credentials are provided via GOOGLE_CREDENTIALS env var (path to SA key JSON
# or inline JSON) — standard GCP SDK convention.

# ── Cloudflare ───────────────────────────────────────────────────────────────

variable "cloudflare_api_token" {
  description = "Cloudflare API token with Zone:Edit + DNS:Edit + Tunnel:Edit permissions. Stored in Vault secret/platform/cloudflare key:api-token."
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID. Stored in Vault secret/platform/cloudflare key:account-id."
  type        = string
}
