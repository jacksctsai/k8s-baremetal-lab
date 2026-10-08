#!/usr/bin/env bash
set -Eeuo pipefail

# install prerequisites
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# create they keyring directory
sudo mkdir -p -m 755 /etc/apt/keyrings

# download the kubenetes signing key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# add the v1.34 repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# install the packages and hold their versions
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet
