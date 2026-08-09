#!/usr/bin/env bash
# Source this file before running `tofu` commands:
#   source ./env.sh
#
# It exports TF_VAR_maas_api_key from the out-of-band ~/.maas-api-key file
# (mode 600, never committed). The TF_VAR_ prefix tells OpenTofu to populate
# the `maas_api_key` variable.
if [ ! -f "$HOME/.maas-api-key" ]; then
  echo "ERROR: ~/.maas-api-key missing. Generate with: maas list | awk '\$1==\"admin\" {print \$3}' > ~/.maas-api-key && chmod 600 ~/.maas-api-key" >&2
  return 1
fi
export TF_VAR_maas_api_key="$(cat "$HOME/.maas-api-key")"
echo "TF_VAR_maas_api_key set (length=${#TF_VAR_maas_api_key})"

# ── AWS ──────────────────────────────────────────────────────────────────────
# Credentials use standard AWS SDK env vars (no TF_VAR_ prefix needed).
# Read from Vault: vault kv get -field=access-key-id secret/platform/aws
if command -v vault >/dev/null 2>&1 && vault token lookup >/dev/null 2>&1; then
  export AWS_ACCESS_KEY_ID="$(vault kv get -field=access-key-id secret/platform/aws 2>/dev/null)"
  export AWS_SECRET_ACCESS_KEY="$(vault kv get -field=secret-access-key secret/platform/aws 2>/dev/null)"
  [ -n "$AWS_ACCESS_KEY_ID" ] && echo "AWS credentials set from Vault"
elif [ -f "$HOME/.aws-minicloud-creds" ]; then
  # fallback: ~/.aws-minicloud-creds contains KEY_ID:SECRET (mode 600)
  export AWS_ACCESS_KEY_ID="$(cut -d: -f1 "$HOME/.aws-minicloud-creds")"
  export AWS_SECRET_ACCESS_KEY="$(cut -d: -f2 "$HOME/.aws-minicloud-creds")"
  echo "AWS credentials set from ~/.aws-minicloud-creds"
else
  echo "WARN: AWS credentials not found — AWS resources will fail. Set via Vault or ~/.aws-minicloud-creds (KEY_ID:SECRET, mode 600)"
fi

# ── Azure ────────────────────────────────────────────────────────────────────
if command -v vault >/dev/null 2>&1 && vault token lookup >/dev/null 2>&1; then
  export TF_VAR_azure_subscription_id="$(vault kv get -field=subscription-id secret/platform/azure 2>/dev/null)"
  export TF_VAR_azure_client_id="$(vault kv get -field=client-id secret/platform/azure 2>/dev/null)"
  export TF_VAR_azure_client_secret="$(vault kv get -field=client-secret secret/platform/azure 2>/dev/null)"
  export TF_VAR_azure_tenant_id="$(vault kv get -field=tenant-id secret/platform/azure 2>/dev/null)"
  [ -n "$TF_VAR_azure_tenant_id" ] && echo "Azure credentials set from Vault"
else
  echo "WARN: Azure credentials not found — Azure resources will fail. Store in Vault secret/platform/azure"
fi

# ── GCP ──────────────────────────────────────────────────────────────────────
# GOOGLE_CREDENTIALS = path to service account key JSON (mode 600)
if [ -f "$HOME/.gcp/minicloud-sa-key.json" ]; then
  export GOOGLE_CREDENTIALS="$HOME/.gcp/minicloud-sa-key.json"
  echo "GCP credentials set from ~/.gcp/minicloud-sa-key.json"
else
  echo "WARN: GCP SA key not found at ~/.gcp/minicloud-sa-key.json — GCP resources will fail"
fi
export TF_VAR_gcp_project_id="${GCP_PROJECT_ID:-minicloud-platform}"

# ── Cloudflare ───────────────────────────────────────────────────────────────
if command -v vault >/dev/null 2>&1 && vault token lookup >/dev/null 2>&1; then
  export TF_VAR_cloudflare_api_token="$(vault kv get -field=api-token secret/platform/cloudflare 2>/dev/null)"
  export TF_VAR_cloudflare_account_id="$(vault kv get -field=account-id secret/platform/cloudflare 2>/dev/null)"
  [ -n "$TF_VAR_cloudflare_api_token" ] && echo "Cloudflare credentials set from Vault"
else
  echo "WARN: Cloudflare credentials not found — Cloudflare resources will fail. Store in Vault secret/platform/cloudflare"
fi
