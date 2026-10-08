#!/usr/bin/env bash
set -Eeuo pipefail

# install containerd
sudo apt-get update
sudo apt-get install -y containerd

# generate default configuration and enable SsytemdCgroup
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# restart and enable containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

