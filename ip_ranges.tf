resource "maas_subnet_ip_range" "cluster_dhcp" {
  subnet   = maas_subnet.cluster.id
  type     = "dynamic"
  start_ip = "10.0.0.10"
  end_ip   = "10.0.0.100"
  comment  = "Added via 'Provide DHCP...' in Web UI."
}
