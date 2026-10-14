# Break-fix drills

Each manifest is committed in its **broken** state so the failure is reproducible. Everything runs in the `drills` namespace. The diagnosis and fix for each drill are in [docs/day3.md](../docs/day3.md).

```bash
kubectl create ns drills
kubectl apply -f drills/<file>.yaml
kubectl delete ns drills   # clean up
```

| # | Manifest | Symptom | Root cause |
|---|----------|---------|------------|
| 01 | `01-bad-image-tag.yaml` | `ErrImagePull` / `ImagePullBackOff` | Image tag `v9.9.9` doesn't exist |
| 02 | `02-oom.yaml` | `OOMKilled`, exit 137, restarts | 64MB allocation against a 32Mi memory limit |
| 03 | `03-crashloop.yaml` | `CrashLoopBackOff`, exit 1 | `command` override exits immediately |
| 04 | `04-pending-cpu.yaml` | Pod stuck `Pending`, `FailedScheduling` | Requests 6 CPUs; workers have 2 allocatable |
| 05 | `05-selector-typo.yaml` | Connection refused, empty endpoints | Service selector `hello-apii` matches no pods |
| 06 | `06-readiness-fail.yaml` | Running but `0/1 READY`, no endpoints | Readiness probe hits `/nope` |
| 07 | `07-pvc-no-sc.yaml` | PVC and pod stuck `Pending` | No StorageClass and no matching PV; fix with `07-fix-pv.yaml` (plus `chown 1000:1000` on the hostPath) |
| 08 | *(no manifest)* | Node `NotReady`, pods evicted after 300s | kubelet stopped on w2 (`sudo systemctl stop kubelet`) |