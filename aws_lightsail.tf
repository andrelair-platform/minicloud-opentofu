# ── Lightsail TURN relay ─────────────────────────────────────────────────────
# Coturn TURN server for Jitsi Meet external video calls.
# Public UDP relay is structurally impossible on-premise (SFR NAT, no public
# UDP port-forwarding). Lightsail nano: $3.50/month including 1 TB transfer —
# cheaper than EC2 t2.micro once TURN relay traffic is accounted for.
#
# Import existing resources:
#   tofu import aws_lightsail_instance.coturn minicloud-coturn
#   tofu import aws_lightsail_static_ip.coturn minicloud-coturn-ip
#   tofu import aws_lightsail_static_ip_attachment.coturn minicloud-coturn-ip

resource "aws_lightsail_instance" "coturn" {
  name              = "turn-coturn-eu"
  availability_zone = "${var.aws_region}a"
  blueprint_id      = "ubuntu_22_04"
  bundle_id         = "nano_3_0" # 512 MB RAM, 1 vCPU, 20 GB SSD, 1 TB transfer
  key_pair_name     = "turn-coturn" # existing key pair — must match or forces replacement

  tags = {
    Project    = "minicloud"
    Role       = "turn-relay"
    ManagedBy  = "opentofu"
    CostCentre = "collab"
  }
}

# aws_lightsail_static_ip and aws_lightsail_static_ip_attachment do not support
# import in the hashicorp/aws provider. The static IP "turn-coturn-ip"
# (54.171.137.209) was attached manually and is reflected via
# aws_lightsail_instance.coturn.public_ip_address (is_static_ip = true).

# ── Firewall rules ────────────────────────────────────────────────────────────
# TURN protocol: UDP/TCP 3478 (signalling + relay), UDP 49152–65535 (media relay).
# SSH restricted to Tailscale CIDR (100.x.x.x) — not exposed to internet.

resource "aws_lightsail_instance_public_ports" "coturn" {
  instance_name = aws_lightsail_instance.coturn.name

  port_info {
    from_port = 3478
    to_port   = 3478
    protocol  = "tcp"
    cidrs     = ["0.0.0.0/0"]
  }

  port_info {
    from_port = 3478
    to_port   = 3478
    protocol  = "udp"
    cidrs     = ["0.0.0.0/0"]
  }

  port_info {
    from_port = 49152
    to_port   = 65535
    protocol  = "udp"
    cidrs     = ["0.0.0.0/0"]
  }

  port_info {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidrs     = ["100.0.0.0/8"] # Tailscale only
  }
}

# ── Outputs ───────────────────────────────────────────────────────────────────

output "coturn_public_ip" {
  description = "Static public IP of the Lightsail TURN relay (turn.devandre.sbs)"
  value       = aws_lightsail_instance.coturn.public_ip_address
}

output "coturn_instance_name" {
  description = "Lightsail instance name"
  value       = aws_lightsail_instance.coturn.name
}

# ── Import command (run once to bring existing instance under OpenTofu) ───────
# tofu import aws_lightsail_instance.coturn turn-coturn-eu
