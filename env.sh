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
