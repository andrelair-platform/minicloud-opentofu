# Changelog

## [0.1.1](https://github.com/andrelair-platform/minicloud-opentofu/compare/minicloud-opentofu-v0.1.0...minicloud-opentofu-v0.1.1) (2026-08-14)


### Features

* add AWS, Azure, GCP, Cloudflare providers alongside MAAS ([#3](https://github.com/andrelair-platform/minicloud-opentofu/issues/3)) ([831870f](https://github.com/andrelair-platform/minicloud-opentofu/commit/831870f4ef6e111f3affb2e70ab388265cc175d3))
* **catalog:** add Backstage catalog-info.yaml (Phase 18) ([e20b230](https://github.com/andrelair-platform/minicloud-opentofu/commit/e20b230b14f97536c3027839b84958c3f2254957))
* codify Lightsail TURN relay as OpenTofu (aws_lightsail.tf) ([#11](https://github.com/andrelair-platform/minicloud-opentofu/issues/11)) ([4b4aa9e](https://github.com/andrelair-platform/minicloud-opentofu/commit/4b4aa9e5aded9512af6906cddc63659c384535e0)), closes [#6](https://github.com/andrelair-platform/minicloud-opentofu/issues/6)
* **machines:** add jetson-orin to non_maas_machines inventory ([bf92ca9](https://github.com/andrelair-platform/minicloud-opentofu/commit/bf92ca995bd2a2179ac4585ba3e9a5b6de78900d))
* **machines:** add star-kitten worker node (10.0.0.8) ([34801cf](https://github.com/andrelair-platform/minicloud-opentofu/commit/34801cf0b619d0230be69a2a68dfd86c7e1b2f5f))
* **phase-11:** initial opentofu repo for MAAS-side state ([238d061](https://github.com/andrelair-platform/minicloud-opentofu/commit/238d0618a879a3d680feeda21992fcf37ec3e9df))


### Bug Fixes

* add key_pair_name to prevent instance replacement, remove unimportable static IP resources ([#13](https://github.com/andrelair-platform/minicloud-opentofu/issues/13)) ([19931fb](https://github.com/andrelair-platform/minicloud-opentofu/commit/19931fbf74fa6be2dfc5e20dc7cd47ebf3a1413d))
* correct Lightsail resource names (turn-coturn-eu / turn-coturn-ip) ([#12](https://github.com/andrelair-platform/minicloud-opentofu/issues/12)) ([f320432](https://github.com/andrelair-platform/minicloud-opentofu/commit/f3204322036bf6893a33a450f4bedf0dd0abdf6b))


### Reverts

* **machines:** remove jetson-orin — not joining infra ([75ee70d](https://github.com/andrelair-platform/minicloud-opentofu/commit/75ee70d906102e7937acff1cac31f55b6a1077ca))

## Changelog

All notable changes to minicloud-opentofu are documented here.

This file is maintained by [release-please](https://github.com/googleapis/release-please).
