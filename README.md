# helm-charts

[![CI](https://img.shields.io/github/actions/workflow/status/rolandjitsu/helm-charts/ci.yml?branch=main&style=flat-square&label=CI)](https://github.com/rolandjitsu/helm-charts/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue?style=flat-square)](./LICENSE)

Helm charts I use often, each published to GHCR as an OCI artifact.

## Charts

| Chart | Description | Install |
| --- | --- | --- |
| [bazelremote](./charts/bazelremote) | Sharded, HA [bazel-remote](https://github.com/buchgr/bazel-remote) cache behind an HAProxy consistent-hash router | `helm install bazelremote oci://ghcr.io/rolandjitsu/charts/bazelremote` |

Pin a version with `--version`, and override defaults with `-f my-values.yaml` or `--set`.
Each chart's README documents its values.

## Versioning and releases

Charts version independently. On every push to `main`, [knope](https://knope.tech) reads the
Conventional Commits since the last tag, bumps each affected chart's `version`, updates its
changelog, tags it `<chart>/vX.Y.Z`, cuts a GitHub release, and CI publishes the packaged
chart to `oci://ghcr.io/rolandjitsu/charts`. A chart's `appVersion` (the upstream app it
deploys) is bumped by hand when intentionally moving upstream. See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Contributing

Issues and PRs welcome. See [CONTRIBUTING.md](./CONTRIBUTING.md) and [AGENTS.md](./AGENTS.md);
be kind per the [Code of Conduct](./CODE_OF_CONDUCT.md).

## License

[Apache-2.0](./LICENSE).
