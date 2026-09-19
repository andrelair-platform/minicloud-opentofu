# Each machine resource is keyed by its MAAS system_id.
# The provider's `maas_machine` resource expects power_type and
# power_parameters; for our power_type=manual nodes, parameters are empty.
#
# We use lifecycle.ignore_changes for fields the MAAS lifecycle owns
# (deployment, commissioning) so that re-imports or re-plans don't try to
# rewrite live state.

locals {
  cluster_machines = {
    set-hog       = { hostname = "set-hog", ip = "10.0.0.2", role = "control-plane" }
    fast-skunk    = { hostname = "fast-skunk", ip = "10.0.0.4", role = "worker" }
    fast-heron    = { hostname = "fast-heron", ip = "10.0.0.7", role = "worker" }
    star-kitten   = { hostname = "star-kitten", ip = "10.0.0.8", role = "worker" }
    loving-gannet = { hostname = "loving-gannet", ip = "10.0.0.9", role = "worker" }
  }

  # swift-mac is part of the k3s/Ansible inventory but is deliberately not a
  # maas_machine resource: Apple EFI cannot PXE boot, so Ubuntu was installed
  # manually. Keep it here so this repository still exposes the complete
  # six-node cluster inventory without claiming MAAS lifecycle ownership.
  non_maas_machines = {
    swift-mac = {
      hostname = "swift-mac"
      ip       = "10.0.0.10"
      role     = "worker"
      reason   = "Apple EFI prevents PXE boot; Ubuntu installed manually"
    }
  }
}

resource "maas_machine" "cluster" {
  for_each = local.cluster_machines

  hostname         = each.value.hostname
  power_type       = "manual"
  power_parameters = jsonencode({})
  pxe_mac_address  = "00:00:00:00:00:00" # placeholder — overwritten on import; ignored on re-plan

  lifecycle {
    ignore_changes = [
      pxe_mac_address,
      power_parameters,
    ]
  }
}
