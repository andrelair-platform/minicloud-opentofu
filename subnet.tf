resource "maas_subnet" "cluster" {
  name       = "10.0.0.0/24"
  cidr       = "10.0.0.0/24"
  gateway_ip = "10.0.0.1"
  fabric     = "0"
  vlan       = "0"
}
