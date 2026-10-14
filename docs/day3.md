# Day 3

Day 3 started with the command `kubectl create ns drills`.


## Drill 01 - Bad image

Use hello-api:v9.9.9.

Manifest: [drills/01-bad-image-tag.yaml](../drills/01-bad-image-tag.yaml)


### Symptom

```
$ date
Tue Oct 13 10:19:50 CST 2026
$ kubectl get pods -n drills
NAME                      READY   STATUS             RESTARTS   AGE
bad-tag-9645fbd7f-97f9t   0/1     ImagePullBackOff   0          48s
```

### Cause

```
$ kubectl describe pod bad-tag-9645fbd7f-97f9t -n drills
Name:             bad-tag-9645fbd7f-97f9t
Namespace:        drills
Priority:         0
Service Account:  default
Node:             w1/192.168.252.3
Start Time:       Tue, 13 Oct 2026 10:19:45 +0800
Labels:           app=bad-tag
                  pod-template-hash=9645fbd7f
Annotations:      <none>
Status:           Pending
IP:               10.244.1.41
IPs:
  IP:           10.244.1.41
Controlled By:  ReplicaSet/bad-tag-9645fbd7f
Containers:
  app:
    Container ID:
    Image:          ghcr.io/jacksctsai/hello-api:v9.9.9
    Image ID:
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       ImagePullBackOff
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-69m7t (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       False
  ContainersReady             False
  PodScheduled                True
Volumes:
  kube-api-access-69m7t:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  87s                default-scheduler  Successfully assigned drills/bad-tag-9645fbd7f-97f9t to w1
  Normal   Pulling    43s (x3 over 87s)  kubelet            Pulling image "ghcr.io/jacksctsai/hello-api:v9.9.9"
  Warning  Failed     42s (x3 over 86s)  kubelet            Failed to pull image "ghcr.io/jacksctsai/hello-api:v9.9.9": rpc error: code = NotFound desc = failed to pull and unpack image "ghcr.io/jacksctsai/hello-api:v9.9.9": failed to resolve image: ghcr.io/jacksctsai/hello-api:v9.9.9: not found
  Warning  Failed     42s (x3 over 86s)  kubelet            Error: ErrImagePull
  Normal   BackOff    5s (x5 over 85s)   kubelet            Back-off pulling image "ghcr.io/jacksctsai/hello-api:v9.9.9"
  Warning  Failed     5s (x5 over 85s)   kubelet            Error: ImagePullBackOff
```

kubelet event NotFound: failed to resolve image ...v9.9.9: not found means the tag doesn't exist in the registry. That's a typo or unpublished tag, not auth (401/403) or network (timeout).

### Fix

```
$ kubectl set image deploy/bad-tag app=ghcr.io/jacksctsai/hello-api:v2.0.1 -n drills
deployment.apps/bad-tag image updated
$ kubectl get pods -n drills
NAME                       READY   STATUS    RESTARTS   AGE
bad-tag-7fdf8db64f-48f8z   1/1     Running   0          7s
$ date
Tue Oct 13 10:22:03 CST 2026
```

The time elapsed: 2m 13s


## Drill 02 - OOM

Set a memory limit of 32Mi and make the container allocate more than that, e.g. command: `["node","-e","Buffer.alloc(64*1024*1024).fill(1); setInterval(()=>{},1000)"]`.

Manifest: [drills/02-oom.yaml](../drills/02-oom.yaml)

### Symptom

```
$ kubectl apply -f drills/02-oom.yaml
deployment.apps/oom created
service/oom created
$ date
Tue Oct 13 16:31:53 CST 2026
$ kubectl get pods -n drills
NAME                   READY   STATUS      RESTARTS      AGE
oom-5795df9486-j2t86   0/1     OOMKilled   2 (27s ago)   28s
$ kubectl describe pod oom-5795df9486-j2t86 -n drills
Name:             oom-5795df9486-j2t86
Namespace:        drills
Priority:         0
Service Account:  default
Node:             w1/192.168.252.3
Start Time:       Tue, 13 Oct 2026 16:31:48 +0800
Labels:           app=oom
                  pod-template-hash=5795df9486
Annotations:      <none>
Status:           Running
IP:               10.244.1.44
IPs:
  IP:           10.244.1.44
Controlled By:  ReplicaSet/oom-5795df9486
Containers:
  app:
    Container ID:  containerd://b84b33deb1d96dee61aff63f801335a4c04a06c5abe2567b6a98ab759f456881
    Image:         ghcr.io/jacksctsai/hello-api:v2.0.1
    Image ID:      ghcr.io/jacksctsai/hello-api@sha256:f0c8a642fb10acbfb2f7829222c8bdc5965b90793b0c4ab0971333a59465d943
    Port:          <none>
    Host Port:     <none>
    Command:
      node
      -e
      const b = Buffer.alloc(64*1024*1024).fill(1); setInterval(() => {}, 1000)
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    137
      Started:      Tue, 13 Oct 2026 16:32:04 +0800
      Finished:     Tue, 13 Oct 2026 16:32:04 +0800
    Ready:          False
    Restart Count:  2
    Limits:
      memory:  32Mi
    Requests:
      memory:     16Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-5l6l5 (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       False
  ContainersReady             False
  PodScheduled                True
Volumes:
  kube-api-access-5l6l5:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  44s                default-scheduler  Successfully assigned drills/oom-5795df9486-j2t86 to w1
  Normal   Pulled     28s (x3 over 44s)  kubelet            Container image "ghcr.io/jacksctsai/hello-api:v2.0.1" already present on machine
  Normal   Created    28s (x3 over 44s)  kubelet            Created container: app
  Normal   Started    28s (x3 over 44s)  kubelet            Started container app
  Warning  BackOff    12s (x3 over 42s)  kubelet            Back-off restarting failed container app in pod oom-5795df9486-j2t86_drills(9639d4df-49ef-4167-addc-437a5ec4b664)
```

It appears to be OOMkilled. However, we don't know how much memory consumption is there and we don't know if it's memory leak or undersized.

Let's find more info on the node VM w1.

```
$ sudo dmesg | grep -i oom
(...skipped...)
[452694.162011] Memory cgroup out of memory: Killed process 1886535 (node) total-vm:594556kB, anon-rss:31616kB, file-rss:31616kB, shmem-rss:0kB, UID:1000 pgtables:432kB oom_score_adj:992
```

This clarifies that it is killed due to the memory cgroup constraints. And it is taking up to 32Mi memory space.

On VM cp, we tried to look at how much memory usuage are there but found nothing.

```
$ kubectl exec oom-5795df9486-j2t86 -n drills -- cat /sys/fs/cgroup/memory.current /sys/fs/cgroup/memory.peak
error: Internal error occurred: unable to upgrade connection: container not found ("app")
```

We assume that container dies within milliseconds, so there's nothing to exec into.

### Cause

The app got terminated in OOMKilled (Exit code: 137). We cannot tell if there is a memory leak as the process got terminated right after launching. But we do know that it takes substantial amount of memory to boot the process.

There is a limit.memory of 32Mi defined in the manifest, which creates memory cgroup constraints. We will release the limit and find the memory peak. After a few minutes, if the memory usage stays the same, we can basically eliminate the up front memory leak.

### Fix

We know that the requests.memory is 16Mi and limits.memory is 32Mi. However, we don't know how much exactly memory the process needs. So we doubled the limits.memory to 64Mi and tried again.

```
$ kubectl set resources deployment/oom -n drills --limits=memory=64Mi
deployment.apps/oom resource requirements updated
$ kubectl get pods -n drills
NAME                   READY   STATUS      RESTARTS      AGE
oom-68795649cf-px5p5   0/1     OOMKilled   1 (10s ago)   11s
```

We then raised the memory limits again (96Mi).

```
$ kubectl set resources deployment/oom -n drills --limits=memory=96Mi
deployment.apps/oom resource requirements updated
$ kubectl get pods -n drills
NAME                  READY   STATUS    RESTARTS   AGE
oom-647855bf6-94n6g   1/1     Running   0          14s
$ kubectl exec deploy/oom -n drills -- cat /sys/fs/cgroup/memory.peak
75624448
```

The memory peak measured 72MiB, we will set the memory limit to 108Mi to leave enough room. And we also raise the memory requests a bit lower to the limit of 80Mi so the nodes taking the pod do not overcommit.

```
$ kubectl set resources deployment/oom -n drills --limits=memory=108Mi --requests=memory=80Mi
deployment.apps/oom resource requirements updated
```


The memory usage stays the same in a few minutes. So we can remove the posibility of memory leak for now.

```
$ kubectl exec deploy/oom -n drills -- cat /sys/fs/cgroup/memory.current
74465280
$ kubectl exec deploy/oom -n drills -- cat /sys/fs/cgroup/memory.current
74383360
$ kubectl exec deploy/oom -n drills -- cat /sys/fs/cgroup/memory.current
74383360
```

```
$ date
Tue Oct 13 16:44:35 CST 2026
```

The time elapsed: 12m 42s


## Drill 03 - CrashLoop

Use command: `["sh","-c","exit 1"]`.

Manifest: [drills/03-crashloop.yaml](../drills/03-crashloop.yaml)

### Symptom

```
$ kubectl apply -f drills/03-crashloop.yaml
deployment.apps/crashloop created
$ date
Tue Oct 13 18:30:28 CST 2026
```

There is an error in the newly created pod. The `Last State` in `kubectl describe pod` tells it was terminated in an exit code of 1.

```
$ kubectl get pods -n drills
NAME                        READY   STATUS   RESTARTS      AGE
crashloop-ff5fcc65f-gkvsd   0/1     Error    2 (15s ago)   16s
$ kubectl describe pod crashloop-ff5fcc65f-gkvsd -n drills
Name:             crashloop-ff5fcc65f-gkvsd
Namespace:        drills
Priority:         0
Service Account:  default
Node:             w1/192.168.252.3
Start Time:       Tue, 13 Oct 2026 18:30:28 +0800
Labels:           app=crashloop
                  pod-template-hash=ff5fcc65f
Annotations:      <none>
Status:           Running
IP:               10.244.1.53
IPs:
  IP:           10.244.1.53
Controlled By:  ReplicaSet/crashloop-ff5fcc65f
Containers:
  app:
    Container ID:  containerd://3e9b172ec0093e26dd16bb05381bb0cbc23272c2cf2545c7214f65b291246d33
    Image:         ghcr.io/jacksctsai/hello-api:v2.0.1
    Image ID:      ghcr.io/jacksctsai/hello-api@sha256:f0c8a642fb10acbfb2f7829222c8bdc5965b90793b0c4ab0971333a59465d943
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      exit 1
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Tue, 13 Oct 2026 18:30:41 +0800
      Finished:     Tue, 13 Oct 2026 18:30:41 +0800
    Ready:          False
    Restart Count:  2
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-24kvl (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       False
  ContainersReady             False
  PodScheduled                True
Volumes:
  kube-api-access-24kvl:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  31s                default-scheduler  Successfully assigned drills/crashloop-ff5fcc65f-gkvsd to w1
  Normal   Pulled     17s (x3 over 30s)  kubelet            Container image "ghcr.io/jacksctsai/hello-api:v2.0.1" already present on machine
  Normal   Created    17s (x3 over 30s)  kubelet            Created container: app
  Normal   Started    17s (x3 over 30s)  kubelet            Started container app
  Warning  BackOff    5s (x3 over 29s)   kubelet            Back-off restarting failed container app in pod crashloop-ff5fcc65f-gkvsd_drills(ec9ee544-b0f5-4aed-953c-6de4752c3caf)
```

Checked the logs but turned out to be nothing.

```
$ kubectl logs crashloop-ff5fcc65f-gkvsd -n drills --previous
(empty result)
```

### Cause

Exit 1 with empty logs means the process ended itself immediately, before printing anything. That points to the entrypoint or command, not the app's code. In Drill 02, exit 137 meant the kernel killed it. In our case, it was intended by the command `sh -c exit 1`.


### Fix

The first attempt was to edit the deployment manifest on the fly, changing from `exit 1` to `exit 0` but it ended up the same as Deployments always restart containers. We should use a Job for tasks that are meant to finish.

We then edited the deployment manifest, remove `["sh", "-c", "exit 1"]` override so the pod can't drift from what's in the Dockerfile. And this time it works.

```
$ kubectl edit deployment crashloop -n drills
deployment.apps/crashloop edited
```

The pod is re-created and landed at Running state.

```
$ kubectl get pods -n drills
NAME                         READY   STATUS    RESTARTS   AGE
crashloop-7b949f667b-5dhkx   1/1     Running   0          32s
$ kubectl describe pod crashloop-7b949f667b-5dhkx -n drills
Name:             crashloop-7b949f667b-5dhkx
Namespace:        drills
Priority:         0
Service Account:  default
Node:             w2/192.168.252.4
Start Time:       Tue, 13 Oct 2026 18:31:50 +0800
Labels:           app=crashloop
                  pod-template-hash=7b949f667b
Annotations:      <none>
Status:           Running
IP:               10.244.2.34
IPs:
  IP:           10.244.2.34
Controlled By:  ReplicaSet/crashloop-7b949f667b
Containers:
  app:
    Container ID:   containerd://12d9b14f92e1c9b8e505f49af781391b4af42c6679145a92006813025b0c5985
    Image:          ghcr.io/jacksctsai/hello-api:v2.0.1
    Image ID:       ghcr.io/jacksctsai/hello-api@sha256:f0c8a642fb10acbfb2f7829222c8bdc5965b90793b0c4ab0971333a59465d943
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Tue, 13 Oct 2026 18:31:51 +0800
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-zrbg5 (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-zrbg5:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  44s   default-scheduler  Successfully assigned drills/crashloop-7b949f667b-5dhkx to w2
  Normal  Pulled     43s   kubelet            Container image "ghcr.io/jacksctsai/hello-api:v2.0.1" already present on machine
  Normal  Created    43s   kubelet            Created container: app
  Normal  Started    43s   kubelet            Started container app
$ date
Tue Oct 13 18:33:03 CST 2026
```

The time elapsed: 2m 35s


## Drill 04 - Pending CPU

Request cpu: "6".

Manifest: [drills/04-pending-cpu.yaml](../drills/04-pending-cpu.yaml)

### Symptom

```
$ kubectl apply -f drills/04-pending-cpu.yaml
deployment.apps/pending-cpu created
$ date
Tue Oct 13 18:51:58 CST 2026
```

After 30 seconds, the pod is still at Pending status.

```
$ kubectl get pods -n drills
NAME                           READY   STATUS    RESTARTS   AGE
pending-cpu-6d8cbc8d67-75xhd   0/1     Pending   0          32s
```

### Cause

The `kubectl describe pod` tells that the requested CPUs cannot be satisfied by any of the nodes.

```
$ kubectl describe pod pending-cpu-6d8cbc8d67-75xhd -n drills
Name:             pending-cpu-6d8cbc8d67-75xhd
Namespace:        drills
Priority:         0
Service Account:  default
Node:             <none>
Labels:           app=pending-cpu
                  pod-template-hash=6d8cbc8d67
Annotations:      <none>
Status:           Pending
IP:
IPs:              <none>
Controlled By:    ReplicaSet/pending-cpu-6d8cbc8d67
Containers:
  app:
    Image:      ghcr.io/jacksctsai/hello-api:v2.0.1
    Port:       <none>
    Host Port:  <none>
    Requests:
      cpu:        6
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-4qzc9 (ro)
Conditions:
  Type           Status
  PodScheduled   False
Volumes:
  kube-api-access-4qzc9:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  48s   default-scheduler  0/3 nodes are available: 1 node(s) had untolerated taint(s), 2 Insufficient cpu. no new claims to deallocate, preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.
```

```
$ kubectl get nodes
NAME   STATUS   ROLES           AGE    VERSION
cp     Ready    control-plane   5d6h   v1.34.12
w1     Ready    <none>          5d6h   v1.34.12
w2     Ready    <none>          5d6h   v1.34.12
```

From the message, 1 node(s) had untolerated taint(s) is cp. The control-plane taint keeps ordinary pods off it. 2 Insufficient cpu is w1 and w2, which don't have 6 CPUs free to allocate. Preemption is not helpful means evicting lower-priority pods wouldn't free enough CPU either.

### Fix

To fix it, first need to check the available CPU for the one of the nodes, say w1.

```
$ kubectl describe node w1
Name:               w1
Roles:              <none>
Labels:             beta.kubernetes.io/arch=arm64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=arm64
                    kubernetes.io/hostname=w1
                    kubernetes.io/os=linux
Annotations:        flannel.alpha.coreos.com/backend-data: {"VNI":1,"VtepMAC":"ea:62:ca:63:68:75"}
                    flannel.alpha.coreos.com/backend-type: vxlan
                    flannel.alpha.coreos.com/kube-subnet-manager: true
                    flannel.alpha.coreos.com/public-ip: 192.168.252.3
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Thu, 08 Oct 2026 12:00:36 +0800
Taints:             <none>
Unschedulable:      false
Lease:
  HolderIdentity:  w1
  AcquireTime:     <unset>
  RenewTime:       Tue, 13 Oct 2026 18:53:58 +0800
Conditions:
  Type                 Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----                 ------  -----------------                 ------------------                ------                       -------
  NetworkUnavailable   False   Thu, 08 Oct 2026 12:08:31 +0800   Thu, 08 Oct 2026 12:08:31 +0800   FlannelIsUp                  Flannel is running on this node
  MemoryPressure       False   Tue, 13 Oct 2026 18:49:16 +0800   Thu, 08 Oct 2026 12:00:36 +0800   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure         False   Tue, 13 Oct 2026 18:49:16 +0800   Thu, 08 Oct 2026 12:00:36 +0800   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure          False   Tue, 13 Oct 2026 18:49:16 +0800   Thu, 08 Oct 2026 12:00:36 +0800   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready                True    Tue, 13 Oct 2026 18:49:16 +0800   Thu, 08 Oct 2026 12:08:36 +0800   KubeletReady                 kubelet is posting ready status
Addresses:
  InternalIP:  192.168.252.3
  Hostname:    w1
Capacity:
  cpu:                2
  ephemeral-storage:  14143556Ki
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  hugepages-32Mi:     0
  hugepages-64Ki:     0
  memory:             2002136Ki
  pods:               110
Allocatable:
  cpu:                2
  ephemeral-storage:  13034701189
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  hugepages-32Mi:     0
  hugepages-64Ki:     0
  memory:             1899736Ki
  pods:               110
System Info:
  Machine ID:                 21dea8b58f31303985e7850dccbbb636
  System UUID:                21dea8b5-8f31-3039-85e7-850dccbbb636
  Boot ID:                    b68ce4a4-5578-41a5-859a-1cde04a6271c
  Kernel Version:             6.8.0-142-generic
  OS Image:                   Ubuntu 24.04.5 LTS
  Operating System:           linux
  Architecture:               arm64
  Container Runtime Version:  containerd://2.2.1
  Kubelet Version:            v1.34.12
  Kube-Proxy Version:
PodCIDR:                      10.244.1.0/24
PodCIDRs:                     10.244.1.0/24
Non-terminated Pods:          (4 in total)
  Namespace                   Name                         CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                         ------------  ----------  ---------------  -------------  ---
  default                     hello-api-bff5655fb-cw2nd    50m (2%)      250m (12%)  64Mi (3%)        128Mi (6%)     24h
  default                     hello-api-bff5655fb-zlpd8    50m (2%)      250m (12%)  64Mi (3%)        128Mi (6%)     24h
  kube-flannel                kube-flannel-ds-fx42x        100m (5%)     0 (0%)      50Mi (2%)        0 (0%)         5d6h
  kube-system                 kube-proxy-r5bf7             0 (0%)        0 (0%)      0 (0%)           0 (0%)         5d6h
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests    Limits
  --------           --------    ------
  cpu                200m (10%)  500m (25%)
  memory             178Mi (9%)  256Mi (13%)
  ephemeral-storage  0 (0%)      0 (0%)
  hugepages-1Gi      0 (0%)      0 (0%)
  hugepages-2Mi      0 (0%)      0 (0%)
  hugepages-32Mi     0 (0%)      0 (0%)
  hugepages-64Ki     0 (0%)      0 (0%)
Events:              <none>
```

w1 currently has 2 CPUs allocatable minus 200m already requested leaves 1800m free. A request of 6 can't fit on any worker, and 1 fits. We change the CPU request to "1" should fix the problem.

```
$ kubectl set resources deployment/pending-cpu -n drills --requests=cpu="1"
deployment.apps/pending-cpu resource requirements updated
$ kubectl get pods -n drills
NAME                           READY   STATUS    RESTARTS   AGE
pending-cpu-5c65678b99-rcwwx   1/1     Running   0          32s
$ kubectl describe node w1
Name:               w1
Roles:              <none>
Labels:             beta.kubernetes.io/arch=arm64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=arm64
                    kubernetes.io/hostname=w1
                    kubernetes.io/os=linux
Annotations:        flannel.alpha.coreos.com/backend-data: {"VNI":1,"VtepMAC":"ea:62:ca:63:68:75"}
                    flannel.alpha.coreos.com/backend-type: vxlan
                    flannel.alpha.coreos.com/kube-subnet-manager: true
                    flannel.alpha.coreos.com/public-ip: 192.168.252.3
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Thu, 08 Oct 2026 12:00:36 +0800
Taints:             <none>
Unschedulable:      false
Lease:
  HolderIdentity:  w1
  AcquireTime:     <unset>
  RenewTime:       Tue, 13 Oct 2026 18:55:40 +0800
Conditions:
  Type                 Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----                 ------  -----------------                 ------------------                ------                       -------
  NetworkUnavailable   False   Thu, 08 Oct 2026 12:08:31 +0800   Thu, 08 Oct 2026 12:08:31 +0800   FlannelIsUp                  Flannel is running on this node
  MemoryPressure       False   Tue, 13 Oct 2026 18:54:24 +0800   Thu, 08 Oct 2026 12:00:36 +0800   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure         False   Tue, 13 Oct 2026 18:54:24 +0800   Thu, 08 Oct 2026 12:00:36 +0800   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure          False   Tue, 13 Oct 2026 18:54:24 +0800   Thu, 08 Oct 2026 12:00:36 +0800   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready                True    Tue, 13 Oct 2026 18:54:24 +0800   Thu, 08 Oct 2026 12:08:36 +0800   KubeletReady                 kubelet is posting ready status
Addresses:
  InternalIP:  192.168.252.3
  Hostname:    w1
Capacity:
  cpu:                2
  ephemeral-storage:  14143556Ki
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  hugepages-32Mi:     0
  hugepages-64Ki:     0
  memory:             2002136Ki
  pods:               110
Allocatable:
  cpu:                2
  ephemeral-storage:  13034701189
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  hugepages-32Mi:     0
  hugepages-64Ki:     0
  memory:             1899736Ki
  pods:               110
System Info:
  Machine ID:                 21dea8b58f31303985e7850dccbbb636
  System UUID:                21dea8b5-8f31-3039-85e7-850dccbbb636
  Boot ID:                    b68ce4a4-5578-41a5-859a-1cde04a6271c
  Kernel Version:             6.8.0-142-generic
  OS Image:                   Ubuntu 24.04.5 LTS
  Operating System:           linux
  Architecture:               arm64
  Container Runtime Version:  containerd://2.2.1
  Kubelet Version:            v1.34.12
  Kube-Proxy Version:
PodCIDR:                      10.244.1.0/24
PodCIDRs:                     10.244.1.0/24
Non-terminated Pods:          (5 in total)
  Namespace                   Name                            CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                            ------------  ----------  ---------------  -------------  ---
  default                     hello-api-bff5655fb-cw2nd       50m (2%)      250m (12%)  64Mi (3%)        128Mi (6%)     24h
  default                     hello-api-bff5655fb-zlpd8       50m (2%)      250m (12%)  64Mi (3%)        128Mi (6%)     24h
  drills                      pending-cpu-5c65678b99-rcwwx    1 (50%)       0 (0%)      0 (0%)           0 (0%)         35s
  kube-flannel                kube-flannel-ds-fx42x           100m (5%)     0 (0%)      50Mi (2%)        0 (0%)         5d6h
  kube-system                 kube-proxy-r5bf7                0 (0%)        0 (0%)      0 (0%)           0 (0%)         5d6h
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests     Limits
  --------           --------     ------
  cpu                1200m (60%)  500m (25%)
  memory             178Mi (9%)   256Mi (13%)
  ephemeral-storage  0 (0%)       0 (0%)
  hugepages-1Gi      0 (0%)       0 (0%)
  hugepages-2Mi      0 (0%)       0 (0%)
  hugepages-32Mi     0 (0%)       0 (0%)
  hugepages-64Ki     0 (0%)       0 (0%)
Events:              <none>
$ date
Tue Oct 13 18:55:48 CST 2026
```


The time elapsed: 3m 50s


## Drill 05 - Selector typo

The Service selector is app: hello-apii, so it has no EndpointSlices.

Manifest: [drills/05-selector-typo.yaml](../drills/05-selector-typo.yaml)

### Symptom

```
$ kubectl apply -f drills/05-selector-typo.yaml
deployment.apps/selector-typo created
service/selector-typo created
$ date
Wed Oct 14 10:31:45 CST 2026
```

After the manifest is applied, the service is up and running. However, the connection to the service is failed. We need the IP and the port of the service to verify the connection.

```
$ kubectl get pods -n drills
NAME                             READY   STATUS    RESTARTS   AGE
selector-typo-6db4cfbc96-65krw   1/1     Running   0          12s
$ kubectl describe pod selector-typo-6db4cfbc96-65krw -n drills
Name:             selector-typo-6db4cfbc96-65krw
Namespace:        drills
Priority:         0
Service Account:  default
Node:             w1/192.168.252.3
Start Time:       Wed, 14 Oct 2026 10:31:41 +0800
Labels:           app=hello-api
                  pod-template-hash=6db4cfbc96
Annotations:      <none>
Status:           Running
IP:               10.244.1.70
IPs:
  IP:           10.244.1.70
Controlled By:  ReplicaSet/selector-typo-6db4cfbc96
Containers:
  app:
    Container ID:   containerd://3ef90efc65c6e1820319490737404927cc3c0dc194c29aa24820ab133f0948b1
    Image:          ghcr.io/jacksctsai/hello-api:v2.0.1
    Image ID:       ghcr.io/jacksctsai/hello-api@sha256:f0c8a642fb10acbfb2f7829222c8bdc5965b90793b0c4ab0971333a59465d943
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Wed, 14 Oct 2026 10:31:42 +0800
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-rbzrg (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-rbzrg:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  22s   default-scheduler  Successfully assigned drills/selector-typo-6db4cfbc96-65krw to w1
  Normal  Pulled     21s   kubelet            Container image "ghcr.io/jacksctsai/hello-api:v2.0.1" already present on machine
  Normal  Created    21s   kubelet            Created container: app
  Normal  Started    21s   kubelet            Started container app
$ kubectl get services -n drills
NAME            TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
selector-typo   NodePort   10.109.74.75   <none>        80:30485/TCP   31s
$ curl -i http://192.168.252.3:30485
curl: (7) Failed to connect to 192.168.252.3 port 30485 after 0 ms: Couldn't connect to server
```


### Cause

Since the pod and service are up and running without problems, we need to further check the problem. Endpoint being the next target.

```
$ kubectl get endpointslice -n drills
NAME                  ADDRESSTYPE   PORTS     ENDPOINTS   AGE
selector-typo-z7hmk   IPv4          <unset>   <unset>     3m18s
```

So there is no endpoint created. Endpoints are generated automatically by matching the Service's selector against pod labels. Let's check what is defined there.

```
$ kubectl get service selector-typo -n drills -o wide
NAME            TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE   SELECTOR
selector-typo   NodePort   10.109.74.75   <none>        80:30485/TCP   89s   app=hello-apii
```

It looks like the SELECTOR contains a typo. To confirm that, we compare it with the pod label.

```
$ kubectl get pods -n drills --show-labels
NAME                             READY   STATUS    RESTARTS   AGE    LABELS
selector-typo-6db4cfbc96-65krw   1/1     Running   0          110s   app=hello-api,pod-template-hash=6db4cfbc96
```

Thus it is clear that the selector contains a typo, thus the service ends up selecting no pods.

### Fix

To fix the problem, we can edit the manifest on the fly, changing selector from app: `hello-apii` to `app: hello-api`.

```
$ kubectl edit service selector-typo -n drills
service/selector-typo edited
```

Then we tested it again, it is working.

```
$ kubectl get pods -n drills
NAME                             READY   STATUS    RESTARTS   AGE
selector-typo-6db4cfbc96-65krw   1/1     Running   0          4m39s
$ kubectl get service -n drills -o wide
NAME            TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE    SELECTOR
selector-typo   NodePort   10.109.74.75   <none>        80:30485/TCP   5m3s   app=hello-api
$ kubectl get endpointslice -n drills
NAME                  ADDRESSTYPE   PORTS   ENDPOINTS     AGE
selector-typo-z7hmk   IPv4          8080    10.244.1.70   5m16s
$ curl -i http://192.168.252.3:30485
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: application/json; charset=utf-8
Content-Length: 143
ETag: W/"8f-c42mkUQ5Hn908FpoPw2yCLnfyEY"
Date: Wed, 14 Oct 2026 02:37:13 GMT
Connection: keep-alive
Keep-Alive: timeout=5

{"greeting":"Hello, World!","version":"v2.0.1","commit":"b338a02","buildAt":"2026-10-12T10:22:06Z","hostname":"selector-typo-6db4cfbc96-65krw"}
$ date
Wed Oct 14 10:37:15 CST 2026
```

The time elapsed: 5m 30s


## Drill 06 - Failing readiness

Point the readiness probe at /nope

Manifest: [drills/06-readiness-fail.yaml](../drills/06-readiness-fail.yaml)

### Symptom

```
$ kubectl apply -f drills/06-readiness-fail.yaml
deployment.apps/readiness-fail created
$ date
Wed Oct 14 11:01:08 CST 2026
```

The pod is Running, however, no pods becomes ready in 16 seconds.

```
$ kubectl get pods -n drills
NAME                             READY   STATUS    RESTARTS   AGE
readiness-fail-8f6d9d56f-s5ptb   0/1     Running   0          16s
```

### Cause

We checked the pod detail, to find what keeps the pod from being ready.

```
$ kubectl describe pod readiness-fail-8f6d9d56f-s5ptb -n drills
Name:             readiness-fail-8f6d9d56f-s5ptb
Namespace:        drills
Priority:         0
Service Account:  default
Node:             w1/192.168.252.3
Start Time:       Wed, 14 Oct 2026 11:01:06 +0800
Labels:           app=readiness-fail
                  pod-template-hash=8f6d9d56f
Annotations:      <none>
Status:           Running
IP:               10.244.1.74
IPs:
  IP:           10.244.1.74
Controlled By:  ReplicaSet/readiness-fail-8f6d9d56f
Containers:
  app:
    Container ID:   containerd://27d0c36985fe45f2227cc0c1436eeacd1a0fdf2b6fb2b876c3f9f570a75dc86f
    Image:          ghcr.io/jacksctsai/hello-api:v2.0.1
    Image ID:       ghcr.io/jacksctsai/hello-api@sha256:f0c8a642fb10acbfb2f7829222c8bdc5965b90793b0c4ab0971333a59465d943
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Wed, 14 Oct 2026 11:01:07 +0800
    Ready:          False
    Restart Count:  0
    Readiness:      http-get http://:8080/nope delay=3s timeout=2s period=5s #success=1 #failure=2
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-hxsbg (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       False
  ContainersReady             False
  PodScheduled                True
Volumes:
  kube-api-access-hxsbg:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  24s               default-scheduler  Successfully assigned drills/readiness-fail-8f6d9d56f-s5ptb to w1
  Normal   Pulled     23s               kubelet            Container image "ghcr.io/jacksctsai/hello-api:v2.0.1" already present on machine
  Normal   Created    23s               kubelet            Created container: app
  Normal   Started    23s               kubelet            Started container app
  Warning  Unhealthy  1s (x4 over 16s)  kubelet            Readiness probe failed: HTTP probe failed with statuscode: 404
```

The problem is clear that the probe was failed in statuscode 404. Looking up at the container definition, the probe is defined as `http://:8080/nope`, which is wrong. The correct probe is located at `/readyz`.

A failing readiness probe never restarts the pod (Restarts stays 0). It only keeps the pod out of the Service's endpoints. If this were a failing liveness probe, kubelet would kill and restart the container.

### Fix

The fix is simple, we can edit the manifest on the fly, re-assigning `readinessProbe.httpGet.path` value to `/readyz`. The pod will be recreated with the correct probe after edits are saved.

```
$ kubectl edit deployment readiness-fail -n drills
deployment.apps/readiness-fail edited
$ kubectl get pods -n drills
NAME                              READY   STATUS    RESTARTS   AGE
readiness-fail-5f47ff5444-s8nkd   0/1     Running   0          6s
readiness-fail-8f6d9d56f-s5ptb    0/1     Running   0          67s
$ kubectl get pods -n drills
NAME                              READY   STATUS    RESTARTS   AGE
readiness-fail-5f47ff5444-s8nkd   1/1     Running   0          13s
$ date
Wed Oct 14 11:02:38 CST 2026
```

We can see that the old pod wasn't killed because the new one wasn't Ready, it is the readiness probe protecting during rollouts.


The time elapsed: 1m 30s


## Drill 07 - PVC with no StorageClass

Leave storageClassName unset on the PVC and mount it in a pod.

Manifest: [drills/07-pvc-no-sc.yaml](../drills/07-pvc-no-sc.yaml)

Supplement manifest: [drills/07-fix-pv.yaml](../drills/07-fix-pv.yaml)

### Symptom

```
$ kubectl apply -f drills/07-pvc-no-sc.yaml
persistentvolumeclaim/data created
deployment.apps/pvc-pending created
$ date
Wed Oct 14 11:31:10 CST 2026
```

However, we see the pod was staying at Pending status. So we describe the pod to find out what got stuck.

```
$ kubectl get pods -n drills
NAME                          READY   STATUS    RESTARTS   AGE
pvc-pending-bbc6fd79d-757l9   0/1     Pending   0          6s
$ kubectl describe pod pvc-pending-bbc6fd79d-757l9 -n drills
Name:             pvc-pending-bbc6fd79d-757l9
Namespace:        drills
Priority:         0
Service Account:  default
Node:             <none>
Labels:           app=pvc-pending
                  pod-template-hash=bbc6fd79d
Annotations:      <none>
Status:           Pending
IP:
IPs:              <none>
Controlled By:    ReplicaSet/pvc-pending-bbc6fd79d
Containers:
  app:
    Image:        ghcr.io/jacksctsai/hello-api:v2.0.1
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:
      /data from data (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-lcqbs (ro)
Conditions:
  Type           Status
  PodScheduled   False
Volumes:
  data:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  data
    ReadOnly:   false
  kube-api-access-lcqbs:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  20s   default-scheduler  0/3 nodes are available: pod has unbound immediate PersistentVolumeClaims. not found
```

### Cause

It turned out the pod has a FailedScheduling at pod has unbound immediate PersistentVolumeClaims. not found.

We further checked the pvc and the only one pvc is Pending with no persistent volumes available for this claim and no storage class is set. Then checking sc and pv resources and found nothing.

```
$ kubectl describe pvc data -n drills
Name:          data
Namespace:     drills
StorageClass:
Status:        Pending
Volume:
Labels:        <none>
Annotations:   <none>
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:
Access Modes:
VolumeMode:    Filesystem
Used By:       pvc-pending-bbc6fd79d-757l9
Events:
  Type    Reason         Age               From                         Message
  ----    ------         ----              ----                         -------
  Normal  FailedBinding  2s (x4 over 46s)  persistentvolume-controller  no persistent volumes available for this claim and no storage class is set
$ kubectl get sc
No resources found
$ kubectl get pv
No resources found
```


### Fix

So there should be a pv defined somewhere, static or dynamic. For this drill we use a static PV; in production a StorageClass with a provisioner creates PVs dynamically.

```
$ kubectl apply -f drills/07-fix-pv.yaml
persistentvolume/data-pv created
$ kubectl get pv,pvc -n drills
NAME                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM         STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/data-pv   1Gi        RWO            Retain           Bound    drills/data                  <unset>                          31s

NAME                         STATUS   VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/data   Bound    data-pv   1Gi        RWO                           <unset>                 108s
```

In a few seconds, we can see the pod becomes ready. And we describe the pod to see the scheduler was able to assign the pod to w1.

```
$ kubectl get pods -n drills
NAME                          READY   STATUS    RESTARTS   AGE
pvc-pending-bbc6fd79d-757l9   1/1     Running   0          2m5s
$ kubectl describe pod pvc-pending-bbc6fd79d-757l9 -n drills
Name:             pvc-pending-bbc6fd79d-757l9
Namespace:        drills
Priority:         0
Service Account:  default
Node:             w1/192.168.252.3
Start Time:       Wed, 14 Oct 2026 11:32:38 +0800
Labels:           app=pvc-pending
                  pod-template-hash=bbc6fd79d
Annotations:      <none>
Status:           Running
IP:               10.244.1.76
IPs:
  IP:           10.244.1.76
Controlled By:  ReplicaSet/pvc-pending-bbc6fd79d
Containers:
  app:
    Container ID:   containerd://729824b0a5b4df9ca446371fc52195563e4e737c5967f72f8e793d4aab51aee2
    Image:          ghcr.io/jacksctsai/hello-api:v2.0.1
    Image ID:       ghcr.io/jacksctsai/hello-api@sha256:f0c8a642fb10acbfb2f7829222c8bdc5965b90793b0c4ab0971333a59465d943
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Wed, 14 Oct 2026 11:32:39 +0800
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /data from data (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-lcqbs (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  data:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  data
    ReadOnly:   false
  kube-api-access-lcqbs:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason            Age                  From               Message
  ----     ------            ----                 ----               -------
  Warning  FailedScheduling  46s (x5 over 2m15s)  default-scheduler  0/3 nodes are available: pod has unbound immediate PersistentVolumeClaims. not found
  Normal   Scheduled         46s                  default-scheduler  Successfully assigned drills/pvc-pending-bbc6fd79d-757l9 to w1
  Normal   Pulled            45s                  kubelet            Container image "ghcr.io/jacksctsai/hello-api:v2.0.1" already present on machine
  Normal   Created           45s                  kubelet            Created container: app
  Normal   Started           45s                  kubelet            Started container app
```

We then try to write some data to the volume to verify it is working.

```
$ kubectl exec deploy/pvc-pending -n drills -- sh -c 'echo hi > /data/t && cat /data/t'
sh: 1: cannot create /data/t: Permission denied
```

The write failed because of a permission issue. To troubleshoot this, we move over to w1 and change the permission.
```
$ ls -alh /mnt/data
total 8.0K
drwxr-xr-x 2 root root 4.0K Oct 14 11:32 .
drwxr-xr-x 3 root root 4.0K Oct 14 11:32 ..
$ sudo chmod o+w /mnt/data
```

The container runs as a non-root user (UID 1000, the Node image's node user). `hostPath` creates `/mnt/data` owned by root with mode 755, so the container user can't write to it. `chmod o+w` works for a drill, but it opens the directory to every user on the node. The cleaner fix is `sudo chown 1000:1000 /mnt/data` on w1. Note that `fsGroup` in `securityContext` doesn't help here, because hostPath volumes ignore it, while volumes created by a provisioner respect it.

And then the command worked.

```
$ kubectl exec deploy/pvc-pending -n drills -- sh -c 'echo hi > /data/t && cat /data/t'
hi
$ date
Wed Oct 14 11:35:31 CST 2026
```

The time elapsed: 4m 21s


## Drill 08 - Kubelet stopped on w2

Run `sudo systemctl stop kubelet` on w2, watch with `kubectl get nodes,pods -A -o wide -w`, then start kubelet again.

### Symptom


```
$ date
Wed Oct 14 11:59:23 CST 2026
```

We stopped the `kubelet` service on w2.

```
ubuntu@w2:~$ sudo systemctl stop kubelet
```

We see pods on w2 go to Terminating and get rescheduled on w1.

```
$ kubectl get pods -A -o wide -w
NAMESPACE      NAME                         READY   STATUS    RESTARTS   AGE     IP              NODE   NOMINATED NODE   READINESS GATES
default        hello-api-7d8858fdb4-7qlr9   1/1     Running   0          16h     10.244.1.66     w1     <none>           <none>
default        hello-api-7d8858fdb4-b55mt   1/1     Running   0          16h     10.244.2.36     w2     <none>           <none>
default        hello-api-7d8858fdb4-htwp5   1/1     Running   0          16h     10.244.2.35     w2     <none>           <none>
kube-flannel   kube-flannel-ds-fs9fz        1/1     Running   0          5d23h   192.168.252.4   w2     <none>           <none>
kube-flannel   kube-flannel-ds-fx42x        1/1     Running   0          5d23h   192.168.252.3   w1     <none>           <none>
kube-flannel   kube-flannel-ds-mpzfq        1/1     Running   0          5d23h   192.168.252.2   cp     <none>           <none>
kube-system    coredns-78db67d8c5-7kjxr     1/1     Running   0          5d23h   10.244.0.2      cp     <none>           <none>
kube-system    coredns-78db67d8c5-86prs     1/1     Running   0          5d23h   10.244.2.8      w2     <none>           <none>
kube-system    etcd-cp                      1/1     Running   0          6d      192.168.252.2   cp     <none>           <none>
kube-system    kube-apiserver-cp            1/1     Running   0          6d      192.168.252.2   cp     <none>           <none>
kube-system    kube-controller-manager-cp   1/1     Running   0          6d      192.168.252.2   cp     <none>           <none>
kube-system    kube-proxy-fbtm5             1/1     Running   0          5d23h   192.168.252.4   w2     <none>           <none>
kube-system    kube-proxy-r5bf7             1/1     Running   0          5d23h   192.168.252.3   w1     <none>           <none>
kube-system    kube-proxy-tkvgx             1/1     Running   0          6d      192.168.252.2   cp     <none>           <none>
kube-system    kube-scheduler-cp            1/1     Running   0          6d      192.168.252.2   cp     <none>           <none>
kube-system    kube-proxy-fbtm5             1/1     Running   0          5d23h   192.168.252.4   w2     <none>           <none>
kube-flannel   kube-flannel-ds-fs9fz        1/1     Running   0          5d23h   192.168.252.4   w2     <none>           <none>
kube-system    coredns-78db67d8c5-86prs     1/1     Running   0          5d23h   10.244.2.8      w2     <none>           <none>
default        hello-api-7d8858fdb4-htwp5   1/1     Running   0          16h     10.244.2.35     w2     <none>           <none>
default        hello-api-7d8858fdb4-b55mt   1/1     Running   0          16h     10.244.2.36     w2     <none>           <none>
default        hello-api-7d8858fdb4-htwp5   1/1     Running   0          16h     10.244.2.35     w2     <none>           <none>
default        hello-api-7d8858fdb4-b55mt   1/1     Running   0          16h     10.244.2.36     w2     <none>           <none>
kube-system    coredns-78db67d8c5-86prs     1/1     Running   0          5d23h   10.244.2.8      w2     <none>           <none>
default        hello-api-7d8858fdb4-htwp5   1/1     Terminating   0          16h     10.244.2.35     w2     <none>           <none>
default        hello-api-7d8858fdb4-b55mt   1/1     Terminating   0          16h     10.244.2.36     w2     <none>           <none>
kube-system    coredns-78db67d8c5-86prs     1/1     Terminating   0          5d23h   10.244.2.8      w2     <none>           <none>
default        hello-api-7d8858fdb4-f2j76   0/1     Pending       0          0s      <none>          <none>   <none>           <none>
default        hello-api-7d8858fdb4-f2j76   0/1     Pending       0          0s      <none>          w1       <none>           <none>
default        hello-api-7d8858fdb4-pjsg4   0/1     Pending       0          0s      <none>          <none>   <none>           <none>
default        hello-api-7d8858fdb4-f2j76   0/1     ContainerCreating   0          0s      <none>          w1       <none>           <none>
default        hello-api-7d8858fdb4-pjsg4   0/1     Pending             0          0s      <none>          w1       <none>           <none>
default        hello-api-7d8858fdb4-pjsg4   0/1     ContainerCreating   0          0s      <none>          w1       <none>           <none>
kube-system    coredns-78db67d8c5-pwz6p     0/1     Pending             0          0s      <none>          <none>   <none>           <none>
kube-system    coredns-78db67d8c5-pwz6p     0/1     Pending             0          0s      <none>          w1       <none>           <none>
kube-system    coredns-78db67d8c5-pwz6p     0/1     ContainerCreating   0          1s      <none>          w1       <none>           <none>
default        hello-api-7d8858fdb4-f2j76   0/1     Running             0          2s      10.244.1.77     w1       <none>           <none>
default        hello-api-7d8858fdb4-pjsg4   0/1     Running             0          2s      10.244.1.78     w1       <none>           <none>
kube-system    coredns-78db67d8c5-pwz6p     0/1     Running             0          2s      10.244.1.79     w1       <none>           <none>
kube-system    coredns-78db67d8c5-pwz6p     1/1     Running             0          3s      10.244.1.79     w1       <none>           <none>
default        hello-api-7d8858fdb4-f2j76   1/1     Running             0          8s      10.244.1.77     w1       <none>           <none>
default        hello-api-7d8858fdb4-pjsg4   1/1     Running             0          8s      10.244.1.78     w1       <none>           <none>
```

And the `kubectl describe node` tells that w2 is NodeNotReady.

```
$ kubectl describe node w2
Name:               w2
Roles:              <none>
Labels:             beta.kubernetes.io/arch=arm64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=arm64
                    kubernetes.io/hostname=w2
                    kubernetes.io/os=linux
Annotations:        flannel.alpha.coreos.com/backend-data: {"VNI":1,"VtepMAC":"1a:01:42:10:e0:2d"}
                    flannel.alpha.coreos.com/backend-type: vxlan
                    flannel.alpha.coreos.com/kube-subnet-manager: true
                    flannel.alpha.coreos.com/public-ip: 192.168.252.4
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Thu, 08 Oct 2026 12:01:10 +0800
Taints:             node.kubernetes.io/unreachable:NoExecute
                    node.kubernetes.io/unreachable:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  w2
  AcquireTime:     <unset>
  RenewTime:       Wed, 14 Oct 2026 11:59:37 +0800
Conditions:
  Type                 Status    LastHeartbeatTime                 LastTransitionTime                Reason              Message
  ----                 ------    -----------------                 ------------------                ------              -------
  NetworkUnavailable   False     Thu, 08 Oct 2026 12:09:55 +0800   Thu, 08 Oct 2026 12:09:55 +0800   FlannelIsUp         Flannel is running on this node
  MemoryPressure       Unknown   Wed, 14 Oct 2026 11:55:10 +0800   Wed, 14 Oct 2026 12:00:30 +0800   NodeStatusUnknown   Kubelet stopped posting node status.
  DiskPressure         Unknown   Wed, 14 Oct 2026 11:55:10 +0800   Wed, 14 Oct 2026 12:00:30 +0800   NodeStatusUnknown   Kubelet stopped posting node status.
  PIDPressure          Unknown   Wed, 14 Oct 2026 11:55:10 +0800   Wed, 14 Oct 2026 12:00:30 +0800   NodeStatusUnknown   Kubelet stopped posting node status.
  Ready                Unknown   Wed, 14 Oct 2026 11:55:10 +0800   Wed, 14 Oct 2026 12:00:30 +0800   NodeStatusUnknown   Kubelet stopped posting node status.
Addresses:
  InternalIP:  192.168.252.4
  Hostname:    w2
Capacity:
  cpu:                2
  ephemeral-storage:  14143556Ki
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  hugepages-32Mi:     0
  hugepages-64Ki:     0
  memory:             2002136Ki
  pods:               110
Allocatable:
  cpu:                2
  ephemeral-storage:  13034701189
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  hugepages-32Mi:     0
  hugepages-64Ki:     0
  memory:             1899736Ki
  pods:               110
System Info:
  Machine ID:                 67913ca926aa36b6b6a3893f9da02b15
  System UUID:                67913ca9-26aa-36b6-b6a3-893f9da02b15
  Boot ID:                    eaf1bf16-a153-42c6-8a61-383be992bcbb
  Kernel Version:             6.8.0-142-generic
  OS Image:                   Ubuntu 24.04.5 LTS
  Operating System:           linux
  Architecture:               arm64
  Container Runtime Version:  containerd://2.2.1
  Kubelet Version:            v1.34.12
  Kube-Proxy Version:
PodCIDR:                      10.244.2.0/24
PodCIDRs:                     10.244.2.0/24
Non-terminated Pods:          (5 in total)
  Namespace                   Name                          CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                          ------------  ----------  ---------------  -------------  ---
  default                     hello-api-7d8858fdb4-b55mt    50m (2%)      250m (12%)  64Mi (3%)        128Mi (6%)     16h
  default                     hello-api-7d8858fdb4-htwp5    50m (2%)      250m (12%)  64Mi (3%)        128Mi (6%)     16h
  kube-flannel                kube-flannel-ds-fs9fz         100m (5%)     0 (0%)      50Mi (2%)        0 (0%)         5d23h
  kube-system                 coredns-78db67d8c5-86prs      100m (5%)     0 (0%)      70Mi (3%)        170Mi (9%)     5d23h
  kube-system                 kube-proxy-fbtm5              0 (0%)        0 (0%)      0 (0%)           0 (0%)         6d
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests     Limits
  --------           --------     ------
  cpu                300m (15%)   500m (25%)
  memory             248Mi (13%)  426Mi (22%)
  ephemeral-storage  0 (0%)       0 (0%)
  hugepages-1Gi      0 (0%)       0 (0%)
  hugepages-2Mi      0 (0%)       0 (0%)
  hugepages-32Mi     0 (0%)       0 (0%)
  hugepages-64Ki     0 (0%)       0 (0%)
Events:
  Type    Reason        Age   From             Message
  ----    ------        ----  ----             -------
  Normal  NodeNotReady  2m6s  node-controller  Node w2 status is now: NodeNotReady
```

### Cause

Apparently, kubelet stopped posting status; the containers keep running, so only the node agent is down, and `systemctl status` confirms it.

```
ubuntu@w2:~$ sudo ctr -n k8s.io containers ls
CONTAINER                                                           IMAGE                                                    RUNTIME
317af2feb0684d322db10f4e73c85e4d11e1c7fe5b1df63d2f5e6566d68ae7fc    registry.k8s.io/pause:3.10.1                             io.containerd.runc.v2
3a76d5ade6bdc9494ed5a7445a55b8833bb72992b1edcebcb4cb766e3aa70d56    ghcr.io/flannel-io/flannel:v0.28.9                       io.containerd.runc.v2
3ad00713089d8de0135c6dd571d541a5a621e9cf386f72b64ec5956e78cb308f    registry.k8s.io/pause:3.10.1                             io.containerd.runc.v2
451102893127dc6b2685ee93444aff240a1d57fa53e5cc00ffad85cc21331b85    ghcr.io/jacksctsai/hello-api:v2.0.1                      io.containerd.runc.v2
5544de6726bc66215098ce967cab0e3545b0f8ff7faf355ec961411d840993f1    ghcr.io/flannel-io/flannel:v0.28.9                       io.containerd.runc.v2
6b2daaa1ef2bb0a835d5e6e2b0694f4b1f5c35683823fcd411b35b349fe0badb    registry.k8s.io/pause:3.10.1                             io.containerd.runc.v2
6e93cb927b2d6928831ef380018fed5ab0ba391fecbf775e5a15076a8f5acbd4    registry.k8s.io/pause:3.10.1                             io.containerd.runc.v2
83454f078e3f5b395e8e978fa8eec37cd78b4e8470d513364164fd4bf6fa386e    registry.k8s.io/coredns/coredns:v1.12.1                  io.containerd.runc.v2
95ed110a8495cc66751f892555f0b8ac0b85550babc330b0190143d1ed1858ed    ghcr.io/flannel-io/flannel-cni-plugin:v1.9.1-flannel3    io.containerd.runc.v2
cd735e130b87078969f4dcc4331ad027582b09213b5928d8528c98480293ff7b    registry.k8s.io/kube-proxy:v1.34.12                      io.containerd.runc.v2
ce8881432582a497c2788bdf561c000b6730c8affa256f9240d0de0a969c1a7f    registry.k8s.io/pause:3.10.1                             io.containerd.runc.v2
fcf0be0e95305035f76a4e353220f73e34b5b0c96eb0afc5e6e9a7cb9fe71655    ghcr.io/jacksctsai/hello-api:v2.0.1                      io.containerd.runc.v2
ubuntu@w2:~$ sudo ctr -n k8s.io tasks ls
TASK                                                                PID        STATUS
3a76d5ade6bdc9494ed5a7445a55b8833bb72992b1edcebcb4cb766e3aa70d56    7911       RUNNING
6b2daaa1ef2bb0a835d5e6e2b0694f4b1f5c35683823fcd411b35b349fe0badb    14460      RUNNING
3ad00713089d8de0135c6dd571d541a5a621e9cf386f72b64ec5956e78cb308f    1904278    RUNNING
451102893127dc6b2685ee93444aff240a1d57fa53e5cc00ffad85cc21331b85    1904341    RUNNING
ce8881432582a497c2788bdf561c000b6730c8affa256f9240d0de0a969c1a7f    7526       RUNNING
317af2feb0684d322db10f4e73c85e4d11e1c7fe5b1df63d2f5e6566d68ae7fc    7752       RUNNING
83454f078e3f5b395e8e978fa8eec37cd78b4e8470d513364164fd4bf6fa386e    15405      RUNNING
6e93cb927b2d6928831ef380018fed5ab0ba391fecbf775e5a15076a8f5acbd4    1904275    RUNNING
fcf0be0e95305035f76a4e353220f73e34b5b0c96eb0afc5e6e9a7cb9fe71655    1904356    RUNNING
cd735e130b87078969f4dcc4331ad027582b09213b5928d8528c98480293ff7b    7553       RUNNING
```

After the eviction, `ctr tasks ls` still showed both hello-api containers RUNNING on w2. The API had already marked them Terminating, but nothing could actually kill them because kubelet was down. A single node can end up running pods the cluster thinks are gone, and this is how. It's also why StatefulSets don't reschedule a pod onto another node until the old node is confirmed dead.

Then we discovered that the kubelet service itself is actually dead.

```
$ sudo systemctl status kubelet
○ kubelet.service - kubelet: The Kubernetes Node Agent
     Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; preset: enabled)
    Drop-In: /usr/lib/systemd/system/kubelet.service.d
             └─10-kubeadm.conf
     Active: inactive (dead) since Wed 2026-10-14 11:59:44 CST; 13min ago
   Duration: 5d 23h 58min 35.161s
       Docs: https://kubernetes.io/docs/
    Process: 7452 ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS (code=exited, status=0/SUCCESS)
   Main PID: 7452 (code=exited, status=0/SUCCESS)
        CPU: 2h 37min 10.465s

Oct 14 11:00:57 w2 kubelet[7452]: I1014 11:00:57.370338    7452 pod_container_deletor.go:53] "DeleteContainer returned error" containerID={"Type":"containerd","ID":">
Oct 14 11:00:57 w2 kubelet[7452]: I1014 11:00:57.413274    7452 reconciler_common.go:163] "operationExecutor.UnmountVolume started for volume \"kube-api-access-vc5t8>
Oct 14 11:00:57 w2 kubelet[7452]: I1014 11:00:57.418253    7452 operation_generator.go:782] UnmountVolume.TearDown succeeded for volume "kubernetes.io/projected/8d9f>
Oct 14 11:00:57 w2 kubelet[7452]: I1014 11:00:57.577417    7452 reconciler_common.go:299] "Volume detached for volume \"kube-api-access-vc5t8\" (UniqueName: \"kubern>
Oct 14 11:00:58 w2 kubelet[7452]: I1014 11:00:58.053280    7452 kubelet_volumes.go:163] "Cleaned up orphaned pod volumes dir" podUID="8d9fe165-5633-4cbd-b73c-f966173>
Oct 14 11:59:44 w2 kubelet[7452]: I1014 11:59:44.784517    7452 dynamic_cafile_content.go:175] "Shutting down controller" name="client-ca-bundle::/etc/kubernetes/pki>
Oct 14 11:59:44 w2 systemd[1]: Stopping kubelet.service - kubelet: The Kubernetes Node Agent...
Oct 14 11:59:44 w2 systemd[1]: kubelet.service: Deactivated successfully.
Oct 14 11:59:44 w2 systemd[1]: Stopped kubelet.service - kubelet: The Kubernetes Node Agent.
Oct 14 11:59:44 w2 systemd[1]: kubelet.service: Consumed 2h 37min 10.465s CPU time, 36.3M memory peak, 0B memory swap peak.
```

### Fix

So we start the kubelet on w2 again.

```
ubuntu@w2:~$ sudo systemctl start kubelet
```

Then we can see w2 is recovering and the status became NodeReady.

```
$ kubectl get pods -A -o wide
NAMESPACE      NAME                         READY   STATUS    RESTARTS   AGE     IP              NODE   NOMINATED NODE   READINESS GATES
default        hello-api-7d8858fdb4-7qlr9   1/1     Running   0          16h     10.244.1.66     w1     <none>           <none>
default        hello-api-7d8858fdb4-f2j76   1/1     Running   0          14m     10.244.1.77     w1     <none>           <none>
default        hello-api-7d8858fdb4-pjsg4   1/1     Running   0          14m     10.244.1.78     w1     <none>           <none>
kube-flannel   kube-flannel-ds-fs9fz        1/1     Running   0          6d      192.168.252.4   w2     <none>           <none>
kube-flannel   kube-flannel-ds-fx42x        1/1     Running   0          6d      192.168.252.3   w1     <none>           <none>
kube-flannel   kube-flannel-ds-mpzfq        1/1     Running   0          6d      192.168.252.2   cp     <none>           <none>
kube-system    coredns-78db67d8c5-7kjxr     1/1     Running   0          5d23h   10.244.0.2      cp     <none>           <none>
kube-system    coredns-78db67d8c5-pwz6p     1/1     Running   0          14m     10.244.1.79     w1     <none>           <none>
kube-system    etcd-cp                      1/1     Running   0          6d      192.168.252.2   cp     <none>           <none>
kube-system    kube-apiserver-cp            1/1     Running   0          6d      192.168.252.2   cp     <none>           <none>
kube-system    kube-controller-manager-cp   1/1     Running   0          6d      192.168.252.2   cp     <none>           <none>
kube-system    kube-proxy-fbtm5             1/1     Running   0          6d      192.168.252.4   w2     <none>           <none>
kube-system    kube-proxy-r5bf7             1/1     Running   0          6d      192.168.252.3   w1     <none>           <none>
kube-system    kube-proxy-tkvgx             1/1     Running   0          6d      192.168.252.2   cp     <none>           <none>
kube-system    kube-scheduler-cp            1/1     Running   0          6d      192.168.252.2   cp     <none>           <none>

$ kubectl describe node w2
Name:               w2
Roles:              <none>
Labels:             beta.kubernetes.io/arch=arm64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=arm64
                    kubernetes.io/hostname=w2
                    kubernetes.io/os=linux
Annotations:        flannel.alpha.coreos.com/backend-data: {"VNI":1,"VtepMAC":"1a:01:42:10:e0:2d"}
                    flannel.alpha.coreos.com/backend-type: vxlan
                    flannel.alpha.coreos.com/kube-subnet-manager: true
                    flannel.alpha.coreos.com/public-ip: 192.168.252.4
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Thu, 08 Oct 2026 12:01:10 +0800
Taints:             <none>
Unschedulable:      false
Lease:
  HolderIdentity:  w2
  AcquireTime:     <unset>
  RenewTime:       Wed, 14 Oct 2026 12:15:04 +0800
Conditions:
  Type                 Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----                 ------  -----------------                 ------------------                ------                       -------
  NetworkUnavailable   False   Thu, 08 Oct 2026 12:09:55 +0800   Thu, 08 Oct 2026 12:09:55 +0800   FlannelIsUp                  Flannel is running on this node
  MemoryPressure       False   Wed, 14 Oct 2026 12:14:23 +0800   Wed, 14 Oct 2026 12:14:23 +0800   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure         False   Wed, 14 Oct 2026 12:14:23 +0800   Wed, 14 Oct 2026 12:14:23 +0800   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure          False   Wed, 14 Oct 2026 12:14:23 +0800   Wed, 14 Oct 2026 12:14:23 +0800   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready                True    Wed, 14 Oct 2026 12:14:23 +0800   Wed, 14 Oct 2026 12:14:23 +0800   KubeletReady                 kubelet is posting ready status
Addresses:
  InternalIP:  192.168.252.4
  Hostname:    w2
Capacity:
  cpu:                2
  ephemeral-storage:  14143556Ki
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  hugepages-32Mi:     0
  hugepages-64Ki:     0
  memory:             2002136Ki
  pods:               110
Allocatable:
  cpu:                2
  ephemeral-storage:  13034701189
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  hugepages-32Mi:     0
  hugepages-64Ki:     0
  memory:             1899736Ki
  pods:               110
System Info:
  Machine ID:                 67913ca926aa36b6b6a3893f9da02b15
  System UUID:                67913ca9-26aa-36b6-b6a3-893f9da02b15
  Boot ID:                    eaf1bf16-a153-42c6-8a61-383be992bcbb
  Kernel Version:             6.8.0-142-generic
  OS Image:                   Ubuntu 24.04.5 LTS
  Operating System:           linux
  Architecture:               arm64
  Container Runtime Version:  containerd://2.2.1
  Kubelet Version:            v1.34.12
  Kube-Proxy Version:
PodCIDR:                      10.244.2.0/24
PodCIDRs:                     10.244.2.0/24
Non-terminated Pods:          (2 in total)
  Namespace                   Name                     CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                     ------------  ----------  ---------------  -------------  ---
  kube-flannel                kube-flannel-ds-fs9fz    100m (5%)     0 (0%)      50Mi (2%)        0 (0%)         6d
  kube-system                 kube-proxy-fbtm5         0 (0%)        0 (0%)      0 (0%)           0 (0%)         6d
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests   Limits
  --------           --------   ------
  cpu                100m (5%)  0 (0%)
  memory             50Mi (2%)  0 (0%)
  ephemeral-storage  0 (0%)     0 (0%)
  hugepages-1Gi      0 (0%)     0 (0%)
  hugepages-2Mi      0 (0%)     0 (0%)
  hugepages-32Mi     0 (0%)     0 (0%)
  hugepages-64Ki     0 (0%)     0 (0%)
Events:
  Type     Reason                   Age                From             Message
  ----     ------                   ----               ----             -------
  Normal   NodeNotReady             14m                node-controller  Node w2 status is now: NodeNotReady
  Normal   Starting                 44s                kubelet          Starting kubelet.
  Warning  InvalidDiskCapacity      44s                kubelet          invalid capacity 0 on image filesystem
  Normal   NodeAllocatableEnforced  44s                kubelet          Updated Node Allocatable limit across pods
  Normal   NodeReady                44s                kubelet          Node w2 status is now: NodeReady
  Normal   NodeHasSufficientMemory  43s (x2 over 44s)  kubelet          Node w2 status is now: NodeHasSufficientMemory
  Normal   NodeHasNoDiskPressure    43s (x2 over 44s)  kubelet          Node w2 status is now: NodeHasNoDiskPressure
  Normal   NodeHasSufficientPID     43s (x2 over 44s)  kubelet          Node w2 status is now: NodeHasSufficientPID

$ date
Wed Oct 14 12:16:08 CST 2026
```

The time elapsed: 16m 45s


### Timeline

- kubelet stopped at 11:59:44.
- Ready=Unknown at 12:00:30, about 46 seconds later, which is the heartbeat grace period of about 40 seconds.
- Pods evicted about 5 minutes after that, which is the 300-second unreachable toleration.


### Restoring

We noticed that all the pods now sit on w1. Kubernetes doesn't move pods back on its own. To spread them again, run `kubectl rollout restart deploy/hello-api` and `kubectl -n kube-system rollout restart deploy/coredns`.

```
$ kubectl rollout restart deploy/hello-api
deployment.apps/hello-api restarted
$ kubectl -n kube-system rollout restart deploy/coredns
deployment.apps/coredns restarted
$ kubectl get pods -A -o wide
NAMESPACE      NAME                         READY   STATUS    RESTARTS   AGE    IP              NODE   NOMINATED NODE   READINESS GATES
default        hello-api-9586b9fc-2nlxx     1/1     Running   0          116s   10.244.2.40     w2     <none>           <none>
default        hello-api-9586b9fc-b8vgg     1/1     Running   0          2m3s   10.244.1.80     w1     <none>           <none>
default        hello-api-9586b9fc-db7b2     1/1     Running   0          2m7s   10.244.2.38     w2     <none>           <none>
kube-flannel   kube-flannel-ds-fs9fz        1/1     Running   0          6d     192.168.252.4   w2     <none>           <none>
kube-flannel   kube-flannel-ds-fx42x        1/1     Running   0          6d     192.168.252.3   w1     <none>           <none>
kube-flannel   kube-flannel-ds-mpzfq        1/1     Running   0          6d     192.168.252.2   cp     <none>           <none>
kube-system    coredns-678f697bcb-4v94w     1/1     Running   0          2m1s   10.244.2.39     w2     <none>           <none>
kube-system    coredns-678f697bcb-wzqbw     1/1     Running   0          2m1s   10.244.1.81     w1     <none>           <none>
kube-system    etcd-cp                      1/1     Running   0          6d     192.168.252.2   cp     <none>           <none>
kube-system    kube-apiserver-cp            1/1     Running   0          6d     192.168.252.2   cp     <none>           <none>
kube-system    kube-controller-manager-cp   1/1     Running   0          6d     192.168.252.2   cp     <none>           <none>
kube-system    kube-proxy-fbtm5             1/1     Running   0          6d     192.168.252.4   w2     <none>           <none>
kube-system    kube-proxy-r5bf7             1/1     Running   0          6d     192.168.252.3   w1     <none>           <none>
kube-system    kube-proxy-tkvgx             1/1     Running   0          6d     192.168.252.2   cp     <none>           <none>
kube-system    kube-scheduler-cp            1/1     Running   0          6d     192.168.252.2   cp     <none>           <none>
```
