---
id: intro
title: Overview
sidebar_label: Overview
slug: /
---

# minicloud OpenTofu

**OpenTofu (Terraform-compatible) configuration** codifying the minicloud bare-metal provisioning layer via the canonical MAAS provider — machines, networks, DNS, and static IP reservations.

## Responsibility

| In scope | Out of scope |
|---|---|
| MAAS machine definitions (4 ThinkPads + swift-mac) | OS configuration post-provision (minicloud-ansible) |
| Static IP reservations (10.0.0.2–10.0.0.10) | k3s cluster bootstrap (minicloud-ansible) |
| MAAS subnets, DHCP, DNS | Helm values (minicloud-gitops) |
| Machine power types (webhook BMC via Temporal) | |

## Stack

| Concern | Choice |
|---|---|
| Engine | OpenTofu 1.9.x |
| Provider | canonical/maas ~2.6 |
| State backend | Local (controller only — run only on controller) |
| Linting | `tofu fmt` + `tofu validate` |

## Cluster topology

| Node | IP | CPU | RAM | Role |
|---|---|---|---|---|
| set-hog | 10.0.0.2 | i7-8565U | 16 GB | k3s control plane |
| fast-skunk | 10.0.0.4 | i7-10510U | 16 GB | k3s worker |
| fast-heron | 10.0.0.7 | i7-8565U | 32 GB | k3s worker |
| star-kitten | 10.0.0.8 | i7-8565U | 32 GB | k3s worker |
| swift-mac | 10.0.0.10 | i7-3615QM | 16 GB | k3s worker |

## Links

- [GitHub repository](https://github.com/andrelair-platform/minicloud-opentofu)
- [Platform documentation](https://andrelair-platform.github.io/minicloud-platform-docs/)
