# k8s-baremetal-lab

A self-built kubeadm cluster I use to practice deploying, operating, and troubleshooting Kubernetes the way a platform team does day-2 work.

## Why
I'm a backend and systems architect with many years of shipping and running production systems. This lab is where I build hands-on Kubernetes operations skill: building the cluster from scratch, breaking it on purpose, and writing up each incident.

## Cluster
| Node | Role          | vCPU | RAM | OS                    |
|------|---------------|------|-----|-----------------------|
| cp   | control plane | 2    | 2G  | Ubuntu 24.04 (arm64)  |
| w1   | worker        | 2    | 2G  | Ubuntu 24.04 (arm64)  |
| w2   | worker        | 2    | 2G  | Ubuntu 24.04 (arm64)  |

- Host: MacBook Pro M1, VMs via Multipass
- Kubernetes v1.34 (kubeadm), containerd 2.2, Flannel CNI

## Quick start
```bash
# on every node
./scripts/disable_swap.sh
./scripts/install_containerd.sh
./scripts/install_kubeadm_kubelet_kubectl.sh

# on cp
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube && sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config && sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# on workers (as root), using the join command printed by kubeadm init
sudo kubeadm join ...
```

## Incident log
| # | Incident | Root cause |
|---|----------|------------|
| 1 | [Pods can't resolve external names](docs/day1.md) | CoreDNS forwarded to the VM gateway's DNS, which refused queries from pods |

## Roadmap
- [x] kubeadm cluster from scratch, CNI, DNS verified
- [ ] REST service: Deployment, Service, ConfigMap, probes, limits, rolling update and rollback
- [ ] Break-fix drills: OOMKilled, ImagePullBackOff, node NotReady, PVC Pending
- [ ] Helm chart and GitOps with Argo CD
- [ ] Monitoring with kube-prometheus-stack
- [ ] Node provisioning with Ansible; in-place version upgrade
- [ ] Raspberry Pi 5 joins as a physical arm64 worker

## Note on the repo name
The cluster currently runs on Multipass VMs on a MacBook Pro M1, built the same way as a bare-metal install: kubeadm, containerd, and a CNI, with no managed Kubernetes or installer shortcuts. A Raspberry Pi 5 joins next as a physical arm64 worker.