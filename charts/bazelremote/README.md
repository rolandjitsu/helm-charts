# bazelremote

A Helm chart that deploys [bazel-remote](https://github.com/buchgr/bazel-remote) as a
**sharded, highly available** [Remote Cache](https://bazel.build/remote/caching) - a
StatefulSet of independent shards behind an HAProxy consistent-hash router. It gives you
cache throughput (load splits across shards) and resilience (losing one shard costs only
~1/N of the keyspace) without any shared volume or replication.

Works with Bazel and any client that speaks the bazel-remote HTTP/gRPC cache protocol
(e.g. ccache with remote storage).

## Install

```sh
helm install bazelremote oci://ghcr.io/rolandjitsu/charts/bazelremote
```

Pin a version with `--version`, and override defaults with `-f my-values.yaml` or `--set`.
See [Configuration](#configuration).

## High availability (sharded + HAProxy)

The cache runs as a StatefulSet of independent shards ([`statefulset.yaml`](./templates/statefulset.yaml)),
one pod per node, each with its own strict-local PVC. There is no shared volume and no
replication between shards.

An HAProxy consistent-hash router ([`haproxy-*.yaml`](./templates)) fronts the shards and
routes each request by a hash of the cache key (`balance uri`). The blob hash is in the
request path, and the PUT that stores it and the GET that reads it share that path, so both
land on the same shard. `hash-type consistent` (Ketama ring) means adding or removing a
shard remaps only ~1/N of the keyspace.

This gives throughput (load splits across shards) and resilience without replication:
losing one shard makes only ~1/N of keys cold, and they miss and refill on the survivors.
Configure your client to soft-fail on remote-cache errors so a shard outage stays invisible.

The two HAProxy pods are stateless and run identical configs, so the routing layer is HA too.

## Storage

Each shard gets its own PVC via `volumeClaimTemplates`, sized by `storage.size`. Keep
`cache.maxSizeGb` (the bazel-remote soft eviction target) at ~85% of `storage.size`:
eviction lags a bursty write load, so on-disk usage overshoots and the headroom avoids
ENOSPC.

By default the chart references whatever `storage.storageClassName` names (empty = the
cluster default class) and creates no StorageClass of its own. The cache is regenerable, so
a StorageClass with a single, node-local replica is ideal - it avoids write amplification
and keeps I/O local. To have the chart create such a class, set:

```yaml
storage:
  createStorageClass: true
  storageClassName: bazelremote
  storageClass:
    name: bazelremote
    provisioner: driver.longhorn.io      # change for your provisioner
    parameters:
      numberOfReplicas: "1"
      dataLocality: strict-local
```

The built-in one-shard-per-node `podAntiAffinity` is **required**, not preferred: with a
strict-local volume, co-locating two shards would share a disk and defeat both the
throughput split and the resilience. `replicas` must therefore be `<=` the number of
schedulable nodes. Override the scheduling entirely with `affinity`/`nodeSelector`/`tolerations`.

## Ingress

The chart exposes a `ClusterIP` Service by default; reach it in-cluster or port-forward it.
Set `ingress.enabled=true` for a standard `networking.k8s.io/v1` Ingress (configurable
`className`, `host`, `annotations`, `tls`). For a non-standard controller (e.g. a Traefik
`IngressRoute` CRD), leave the Ingress off and manage the route as a separate manifest
pointing at the Service.

## Configuration

| Key | Default | Description |
| --- | --- | --- |
| `image.repository` | `buchgr/bazel-remote-cache` | bazel-remote image; override for a fork/mirror |
| `image.tag` | `""` | Image tag; empty uses the chart `appVersion` |
| `image.pullPolicy` | `IfNotPresent` | |
| `imagePullSecrets` | `[]` | Pull secrets for shard and router images |
| `replicas` | `2` | Number of shards (one pod per node) |
| `cache.maxSizeGb` | `425` | `BAZEL_REMOTE_MAX_SIZE`, GiB; keep ~85% of `storage.size` |
| `cache.storageMode` | `uncompressed` | `uncompressed` or `zstd` |
| `cache.disableHttpAcValidation` | `true` | `BAZEL_REMOTE_DISABLE_HTTP_AC_VALIDATION` |
| `cache.accessLogLevel` | `none` | Per-request access logging |
| `cache.enableEndpointMetrics` | `true` | Prometheus per-endpoint metrics |
| `cache.goMaxProcs` | `"6"` | `GOMAXPROCS`; keep in sync with `resources.requests.cpu` |
| `storage.size` | `500Gi` | Per-shard PVC size |
| `storage.storageClassName` | `""` | StorageClass for PVCs; empty = cluster default |
| `storage.createStorageClass` | `false` | Also render the StorageClass below |
| `storage.storageClass.*` | Longhorn defaults | Provisioner, reclaim policy, parameters |
| `resources` | 6 CPU / 4-8Gi | Shard requests/limits (no CPU limit on purpose) |
| `podSecurityContext.fsGroup` | `1000` | PV write access for the shard |
| `podAnnotations` | `{}` | Extra annotations on shard pods (e.g. metrics-scraper opt-in) |
| `podLabels` | `{}` | Extra labels on shard pods, merged with the fixed `app` selector label |
| `nodeSelector` / `tolerations` / `affinity` | `{}` / `[]` / `{}` | Shard scheduling; empty `affinity` uses the required anti-affinity |
| `service.type` | `ClusterIP` | Public Service type |
| `service.port` | `8080` | Public Service port |
| `haproxy.image.repository` / `.tag` | `haproxy` / `3.0` | Router image |
| `haproxy.replicas` | `2` | Router replicas (HA) |
| `haproxy.resolver` | `kube-dns.kube-system.svc.cluster.local` | Cluster DNS for runtime shard resolution |
| `haproxy.resources` | 200m / 64-256Mi | Router requests/limits |
| `haproxy.nodeSelector` / `.tolerations` / `.affinity` | `{}` / `[]` / `{}` | Router scheduling |
| `ingress.enabled` | `false` | Render a standard Ingress |
| `ingress.className` / `.host` / `.path` / `.pathType` / `.annotations` / `.tls` | see `values.yaml` | Ingress config |

Full defaults and inline comments: [`values.yaml`](./values.yaml).

## Consuming as a shared chart (ArgoCD)

Because the chart is published to GHCR as an OCI artifact, several clusters/repos can pull
the one versioned chart and supply their own values. With ArgoCD, use a multi-source
Application - an OCI Helm source plus a git source that provides the values file:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bazelremote
spec:
  sources:
    - repoURL: ghcr.io/rolandjitsu/charts
      chart: bazelremote
      targetRevision: 0.1.0            # pin the chart version
      helm:
        valueFiles:
          - $values/path/to/values.yaml
    - repoURL: https://your.git/your-repo.git
      targetRevision: HEAD
      ref: values
  destination:
    server: https://kubernetes.default.svc
    namespace: bazelremote
```

The values file carries your environment specifics (private `image.repository` +
`imagePullSecrets`, `nodeSelector`, `storage.storageClassName`/`createStorageClass`, and so
on), so the sharding/HA logic stays in the shared chart and is never copy-pasted.

## Credits

Deploys [bazel-remote](https://github.com/buchgr/bazel-remote) by Jakob Buchgraber and
contributors. This chart only packages and shards it.
