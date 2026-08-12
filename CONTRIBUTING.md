# Contributing

Thanks for contributing. These guidelines keep history clean and review fast.

## Ground rules

1. Commits follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).
2. Keep commits small and self-contained so each can be reviewed on its own. Never mix
   unrelated changes in one commit.
3. CI must be green before review: chart lint, rendered-manifest validation, and typos.
4. Address review feedback by amending the relevant commit and rebasing, not with follow-up
   `fix: typo` commits. Keep history linear.
5. Document every value. A new value gets an entry in the chart's `values.yaml` (with an
   inline comment) and its README table.

## Commit messages

A Conventional Commits subject in the present tense, imperative voice (`feat: add TLS values`,
not `added` or `adds`), then an imperative body that explains *why* when it is not obvious,
wrapped at ~72 columns, ASCII only (no em-dash, no `--`).

This is a **mono-repo**: today it has one chart, so unscoped commits release it. When a second
chart is added, scope each chart-affecting commit with the chart name so releases map to the
right chart (and update `knope.toml` per the note there):

```
feat(bazelremote): add configurable pod tolerations
```

AI-assisted commits disclose the assistant with an `Assisted-by:` trailer, following the kernel
[coding-assistants guidance](https://docs.kernel.org/process/coding-assistants.html). Do not use
`Co-Authored-By`.

```
feat(bazelremote): add configurable pod tolerations

Some clusters taint the cache nodes; expose tolerations so shards can still
schedule there without forking the chart.

Assisted-by: Claude:claude-opus-4-8
```

Agents have extra rules in [AGENTS.md](./AGENTS.md).

## Releases and versioning

Releases are automatic. On push to `main`, [knope](https://knope.tech) reads the commits since
the last tag, bumps each affected chart's `version` (semver from the commit types), updates the
chart's `CHANGELOG.md`, tags `<chart>/vX.Y.Z`, and cuts a GitHub release; CI then packages and
pushes the chart to `oci://ghcr.io/rolandjitsu/charts`. Do not bump `version` or edit a
changelog by hand.

A chart's `appVersion` (the upstream app version it deploys) is **not** automatic - bump it by
hand in `Chart.yaml` when you intentionally move to a newer upstream release, e.g.:

```
feat(bazelremote): track bazel-remote v2.6.2
```

That commit rides the normal release, bumping the chart `version` in the same cycle.

## Development

You need [helm](https://helm.sh) and [kubeconform](https://github.com/yannh/kubeconform).

```shell
# Lint a chart.
helm lint charts/bazelremote

# Render and validate against the Kubernetes schemas (exercise the conditional templates too).
helm template release charts/bazelremote | kubeconform -strict -summary -ignore-missing-schemas
helm template release charts/bazelremote --set ingress.enabled=true --set storage.createStorageClass=true \
  | kubeconform -strict -summary -ignore-missing-schemas
```

Install [prek](https://github.com/j178/prek) and enable the git hooks once. They run typos and
`helm lint` on commit and a Conventional Commits check on the message:

```shell
brew install prek   # or: cargo install --locked prek
prek install
```

## Chart style

- Keep templates minimal and readable. Comments justify *why* a setting is what it is (the
  sharding/HA rationale is the value of these charts); do not narrate the obvious.
- Every configurable value has a sane, public default in `values.yaml`. Charts must render and
  validate with defaults and never hardcode environment-specific infrastructure (registries,
  pull secrets, node selectors, storage classes, hostnames) - surface those as values.
