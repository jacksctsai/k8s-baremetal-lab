Notes

Day 1

Initially, we use multipass to create three VMs on my mac, named cp, w1 and w2.
Then we've created the scripts to do the followings on the three VMs:
- disable swap (permanently) `disable_swap.sh`
- install containerd `install_containerd.sh`
- install kubelet, kubeadm, and kubectl `install_kubeadm_kubelet_kubectl.sh`

We use VM cp to create kubernetes cluster in the following command.
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

After kubernetes cluster is created, the `kubeadm join` command in the output is used on w1 and w2 but failed. It had to run as root to have the permission required.

Then the two nodes are joined successfully.

Also, we missed the commands to Configure kubectl for the Regular User. And that caused some trouble.

After the regular user is configured for kubectl, we were able to run `kubectl get nodes` successfully.

However, the first run gave three nodes status NotReady, which becomes Ready in a few minutes.

Nodes stayed NotReady until the Flannel DaemonSet was running, which is expected because the kubelet reports NotReady until a CNI is configured.

Then we tested the pods with the nslookup command but it failed. I created a full report on the incident attached below.


Symptom

`nslookup kubernetes.default` command failed across the pods.

```
$ kubectl run t --image=busybox --rm -it -- nslookup kubernetes.default

** server can't find kubernetes.default: SERVFAIL
```

Investigation

Checked the CoreDNS log. CoreDNS does not recognize the domain name `kubernetes.default` so the query gets routed to the upstream DNS server `192.168.252.1`, and connection got refused.

```
ubuntu@cp:~$ kubectl -n kube-system logs -l k8s-app=kube-dns
[ERROR] plugin/errors: 2 kubernetes.default. AAAA: read udp 10.244.1.3:42496->192.168.252.1:53: read: connection refused
[ERROR] plugin/errors: 2 kubernetes.default. A: read udp 10.244.1.3:57911->192.168.252.1:53: read: connection refused
[ERROR] plugin/errors: 2 kubernetes.default. AAAA: read udp 10.244.1.3:38293->192.168.252.1:53: read: connection refused
[ERROR] plugin/errors: 2 kubernetes.default. A: read udp 10.244.1.3:45671->192.168.252.1:53: i/o timeout
```

Root cause

Cluster names like kubernetes.default.svc.cluster.local resolve inside CoreDNS. The short name kubernetes.default was sent without the search suffix, so CoreDNS forwarded it to the node's upstream 192.168.252.1, the Mac's VM network gateway, which refused queries coming from pods.

Fix and verification

Forward to public resolvers instead of the node's upstream. Edit the CoreDNS config to specify the DNS resolver rather than relying on the upstream host DNS by the default configuration.

`$ kubectl -n kube-system edit configmap coredns`

Change `forward . /etc/resolv.conf` to `forward . 1.1.1.1 8.8.8.8`, so the DNS queries are forwarded to the public working DNS server.

First the correct local DNS name is working.

```
$ kubectl run t --image=busybox:1.28 --rm -it --restart=Never -- nslookup kubernetes.default.svc.cluster.local
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes.default.svc.cluster.local
Address 1: 10.96.0.1 kubernetes.default.svc.cluster.local

```

Then the google.com resolves.

```
$ kubectl run t --image=busybox:1.28 --rm -it --restart=Never -- nslookup google.com
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      google.com
Address 1: 2404:6800:4008:c13::65 ta-in-f101.1e100.net
(following output ignored)
```

