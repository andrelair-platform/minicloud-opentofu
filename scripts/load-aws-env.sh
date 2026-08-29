# Load AWS credentials from Vault for the on-prem/cloud OpenTofu here (MAAS +
# the AWS Lightsail TURN in aws_lightsail.tf).
#
#   source scripts/load-aws-env.sh   # then: tofu plan / tofu apply
#
# REPOINT (2026-08-29): the old Vault `AWS_ADMIN_*` key was a ROOT account key and
# has been DEACTIVATED. Use the scoped IAM user `minicloud-tofu` instead
# (Vault aws-tofu-*). No secrets in this file — fetched from Vault at run time.
# Run on the controller (has ~/.vault-ops-token).

_vault_addr="${VAULT_ADDR:-https://vault.10.0.0.200.nip.io}"
_vault_tok="$(cat "$HOME/.vault-ops-token" 2>/dev/null || cat "$HOME/.vault-root-token" 2>/dev/null)"

if [ -z "$_vault_tok" ]; then
  echo "load-aws-env: no Vault token (~/.vault-ops-token). Run on the controller." >&2
else
  _j="$(curl -sk -H "X-Vault-Token: $_vault_tok" "$_vault_addr/v1/secret/data/platform/cloud-providers")"
  _g() { printf '%s' "$_j" | python3 -c "import sys,json;print(json.load(sys.stdin)['data']['data']['$1'])"; }
  export AWS_ACCESS_KEY_ID="$(_g aws-tofu-access-key-id)"
  export AWS_SECRET_ACCESS_KEY="$(_g aws-tofu-secret-access-key)"
  export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-eu-west-1}"
  unset _j _vault_tok
  echo "load-aws-env: AWS creds loaded from Vault (minicloud-tofu — root key deactivated)"
fi
