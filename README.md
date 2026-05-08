# minicloud — OpenTofu (MAAS)

Codifies the **MAAS-managed infrastructure** for the 3-node minicloud
cluster: cluster subnet, DHCP range, and the 3 machines.

This is the layer below Phase 10's Ansible roles. Ansible codifies what
runs *on* a node; this OpenTofu codifies the MAAS-side state that makes a
node bootable in the first place.

The cluster is live, so the workflow here is **import-then-plan-clean**, not
`tofu apply` from scratch. The proof of correctness is `tofu plan` returning
"No changes. Your infrastructure matches the configuration."

---

## Layout

```
opentofu/
  versions.tf          # required_version + canonical/maas provider ~> 2.5
  provider.tf          # provider "maas" — reads url + key from variables
  variables.tf         # maas_api_url (default), maas_api_key (sensitive)
  env.sh               # source-able: exports TF_VAR_maas_api_key from ~/.maas-api-key
  subnet.tf            # maas_subnet.cluster — 10.0.0.0/24
  ip_ranges.tf         # maas_subnet_ip_range.cluster_dhcp — 10.0.0.10..100
  machines.tf          # maas_machine.cluster (for_each over 3 hosts)
  outputs.tf           # subnet_id, machine inventory, set_hog_ip, fast_*_ip
  .gitignore           # .terraform/, *.tfstate, *.tfvars
```

---

## Prerequisites

* OpenTofu ≥ 1.10 — install the [tarball](https://github.com/opentofu/opentofu/releases) into `~/.local/bin` (no sudo needed).
* MAAS API key cached at `~/.maas-api-key` (mode 600). Easiest way to grab
  it from a logged-in admin profile:

  ```bash
  maas list | awk '$1=="admin" {print $3}' > ~/.maas-api-key && chmod 600 ~/.maas-api-key
  ```

  If you need a fresh key, run `sudo maas apikey --username admin > ~/.maas-api-key && chmod 600 ~/.maas-api-key`.

---

## Run

Always source `env.sh` first — it exports `TF_VAR_maas_api_key`:

```bash
source ./env.sh
tofu init
tofu plan       # expect: "No changes. Your infrastructure matches..."
tofu output     # subnet, machine inventory, per-host IPs
```

> The `MAAS_API_URL` defaults to `http://localhost:5240/MAAS`. The provider
> appends `/api/2.0/` itself — **do not** include it in the URL.

---

## Importing existing state

Already done for the live cluster (state file `terraform.tfstate` is local
and gitignored). For reference, the import commands were:

```bash
tofu import maas_subnet.cluster 3
tofu import maas_subnet_ip_range.cluster_dhcp 1
tofu import 'maas_machine.cluster["set-hog"]'    nbc6cx
tofu import 'maas_machine.cluster["fast-skunk"]' sby3w7
tofu import 'maas_machine.cluster["fast-heron"]' q6m3px
```

The IDs (`3`, `1`, system_ids) come from `maas admin subnets read`,
`maas admin ipranges read`, `maas admin machines read`.

---

## The import-plan loop

After every import, `tofu plan` will likely report some "drift" — fields the
provider returned that aren't in your `.tf`. The right move is **never to
`apply`** that drift away. Instead, edit the `.tf` file to match what the
plan output shows, and re-plan, until plan reports zero changes.

For this cluster the loop took one iteration: imported subnet didn't have
`fabric` and `vlan` in the `.tf`, plan reported them as `"0" -> null`, we
added `fabric = "0"` and `vlan = "0"` to `subnet.tf`, plan went clean.

This is the only safe way to bring brownfield infrastructure under
management. Applying the diff is what destroys live data.

---

## When (and when not) to `tofu apply`

**Don't apply against this live MAAS** unless you're rebuilding the cluster
from scratch — every machine in `Deployed` state is hosting workloads, and
the provider's machine resource lifecycle could trigger commission/deploy
operations that would reboot nodes.

The legitimate use of `apply` is on a **fresh MAAS controller** to recreate
the inventory:

1. Stand up MAAS, log in, get a fresh API key.
2. `source ./env.sh` (with the new key).
3. `tofu apply` — creates subnet, IP range, and (importantly) registers the
   3 machines by their PXE MAC addresses so they enlist when powered on.
4. Re-import the resulting resources into the *original* state file if
   you're restoring rather than starting clean.

For day-to-day cluster operations, prefer `tofu plan` as a drift detector
and modify state via the MAAS UI / CLI as needed.

---

## Troubleshooting

### `Unable to get MAAS version: 404 Not Found (.../api/2.0/api/2.0/version/.)`

The `maas_api_url` was set to include `/api/2.0` — the provider appends it
itself. Use `http://localhost:5240/MAAS` (no `/api/2.0`).

### `Provider has moved to canonical/maas`

The `maas/maas` source still works as a redirect, but you should update
`versions.tf` to `source = "canonical/maas"` and re-run `tofu init`.

### Plan reports drift on `fabric`, `vlan`, or other unset fields

Update the `.tf` to declare what the provider returns. Don't `apply` to
"reset" them — that's destructive on a live system.

### `tofu output` returns empty

Run `tofu refresh` first to populate state with computed outputs, then
`tofu output`.

---

## What this repo deliberately does NOT manage

* **k3s itself.** Phase 1's docs install k3s; Ansible's Phase 10 keeps the
  prereqs in shape. OpenTofu is for the layer below.
* **Kubernetes resources.** That's helm-chart values files (Phases 5–9) and
  ArgoCD (Phase 12). Mixing IaC tools per layer keeps each focused.
* **DNS records, fabrics, VLAN config.** MAAS already manages these and we
  haven't needed to mutate them. Add them as needed.
* **Crossplane.** A fundamentally different paradigm (IaC *inside*
  Kubernetes); will be its own phase rather than appended here.
