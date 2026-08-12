---
name: Bug Report
about: Report a chart that does not render or deploy as documented
title: "[BUG] "
labels: bug
assignees: ''

---

**Chart and version**
- Chart (e.g. `bazelremote`):
- Chart version (`helm show chart oci://ghcr.io/rolandjitsu/charts/<chart>`):
- Helm version (`helm version`):
- Kubernetes version / distribution:

**Describe the bug**
A clear and concise description of what goes wrong.

**To reproduce**
The values you set and how you installed/rendered the chart:

```sh
helm template release oci://ghcr.io/rolandjitsu/charts/<chart> \
  --version <x.y.z> \
  -f my-values.yaml
```

```yaml
# my-values.yaml (redact any secrets)
```

**Expected behavior**
What you expected the rendered manifests or the running deployment to do.

**Actual output**
The relevant rendered manifest, `helm` error, or `kubectl` state (events, pod logs).

**Additional context**
Anything else that helps: cluster specifics, storage provisioner, ingress controller.
