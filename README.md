# k8s-baremetal-lab

A self-built kubeadm cluster I use to practice deploying, operating, and troubleshooting Kubernetes the way a platform team does day-2 work.

## Why
I'm a backend and systems architect with a track record of shipping and running production systems. This lab is where I build hands-on Kubernetes operations skill: building the cluster from scratch, breaking it on purpose, and writing up each incident.

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

## Deploy the app
The `hello-api` service is packaged as a Helm chart in [charts/hello-api](charts/hello-api).

```bash
helm install hello-api charts/hello-api
```

## Incident log
| # | Incident | Root cause |
|---|----------|------------|
| 1 | [Pods can't resolve external names](docs/day1.md) | CoreDNS forwarded to the VM gateway's DNS, which refused queries from pods |
| 2 | [Pod deletion took ~30s](docs/day2.md) | Node as PID 1 ignored SIGTERM with no handler, so kubelet waited out the 30s grace period and then sent SIGKILL |
| 3 | [Requests dropped during rolling update](docs/day2.md) | The pod stopped serving before endpoint removal reached kube-proxy on every node; fixed with a `preStop` sleep |
| 4 | [Helm couldn't adopt existing resources](docs/day4.md) | Deployment selectors are immutable and the old Service held NodePort 30080; cut over with a delete and reinstall |

Eight break-fix drills live in [drills/](drills/README.md).

## Roadmap
- [x] kubeadm cluster from scratch, CNI, DNS verified
- [x] REST service: Deployment, Service, ConfigMap, probes, limits, rolling update and rollback
- [x] Break-fix drills: ImagePullBackOff, OOMKilled, CrashLoopBackOff, unschedulable pod, Service selector mismatch, failing readiness probe, PVC Pending, node NotReady
- [x] Helm chart: templated values, config-checksum rollouts, upgrade and rollback
- [ ] GitOps with Argo CD
- [ ] Monitoring with kube-prometheus-stack
- [ ] Node provisioning with Ansible; in-place version upgrade
- [ ] Raspberry Pi 5 joins as a physical arm64 worker

## Note on the repo name
The cluster currently runs on Multipass VMs on a MacBook Pro M1, built the same way as a bare-metal install: kubeadm, containerd, and a CNI, with no managed Kubernetes or installer shortcuts. A Raspberry Pi 5 joins next as a physical arm64 worker.