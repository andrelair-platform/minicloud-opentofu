output "subnet_id" {
  description = "MAAS subnet ID for the cluster network"
  value       = maas_subnet.cluster.id
}

output "subnet_cidr" {
  description = "Cluster subnet CIDR"
  value       = maas_subnet.cluster.cidr
}

output "subnet_gateway" {
  description = "Cluster subnet default gateway"
  value       = maas_subnet.cluster.gateway_ip
}

output "dhcp_range" {
  description = "Dynamic DHCP range advertised by MAAS"
  value       = "${maas_subnet_ip_range.cluster_dhcp.start_ip}–${maas_subnet_ip_range.cluster_dhcp.end_ip}"
}

# Per-machine outputs — combine MAAS state (system_id, hostname, MAC) with
# the static IP / role mapping declared in locals.cluster_machines.
output "machines" {
  description = "MAAS-managed machine inventory: hostname, system_id, IP, role, PXE MAC"
  value = {
    for k, m in maas_machine.cluster :
    k => {
      hostname  = m.hostname
      system_id = m.id
      ip        = local.cluster_machines[k].ip
      role      = local.cluster_machines[k].role
      pxe_mac   = m.pxe_mac_address
    }
  }
}

output "non_maas_machines" {
  description = "Cluster nodes intentionally outside MAAS lifecycle management"
  value       = local.non_maas_machines
}

output "cluster_inventory" {
  description = "Complete six-node cluster inventory, including the manually provisioned swift-mac"
  value = merge(
    {
      for k, m in maas_machine.cluster :
      k => {
        hostname   = m.hostname
        system_id  = m.id
        ip         = local.cluster_machines[k].ip
        role       = local.cluster_machines[k].role
        managed_by = "maas"
      }
    },
    {
      for k, m in local.non_maas_machines :
      k => {
        hostname   = m.hostname
        system_id  = null
        ip         = m.ip
        role       = m.role
        managed_by = "manual"
      }
    }
  )
}

# Convenience single-value outputs (matches the Phase 11 verification
# roadmap: `tofu output set_hog_ip` returns the IP).
output "set_hog_ip" {
  description = "Control-plane node IP"
  value       = local.cluster_machines["set-hog"].ip
}

output "fast_skunk_ip" {
  description = "Worker fast-skunk IP"
  value       = local.cluster_machines["fast-skunk"].ip
}

output "fast_heron_ip" {
  description = "Worker fast-heron IP"
  value       = local.cluster_machines["fast-heron"].ip
}

output "loving_gannet_ip" {
  description = "Worker loving-gannet IP"
  value       = local.cluster_machines["loving-gannet"].ip
}

output "swift_mac_ip" {
  description = "Manually provisioned worker swift-mac IP"
  value       = local.non_maas_machines["swift-mac"].ip
}
