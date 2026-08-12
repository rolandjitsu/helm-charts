# AGENTS.md

Guidance for AI coding agents in this repo. Human contributors: see [CONTRIBUTING.md](./CONTRIBUTING.md).

## Workflow

- Clarify the design before implementing. For anything non-trivial, agree on the approach first.
- One unit of change per commit. Never mix unrelated changes. Present the change for review
  before committing.
- Verify against the tools: render before you assert. Run local CI before calling it done, and
  do not claim it passes without running it.

Local CI:

```shell
helm lint charts/<chart>
helm template release charts/<chart> | kubeconform -strict -summary -ignore-missing-schemas
```

## Writing: templates, comments, docs, commits

- Concise and to the point. No fluff. Explain the non-obvious; do not narrate the obvious.
- ASCII only. No em-dash and no `--`; write `-`. Do not use any non-ASCII glyph: write `->` for
  the right arrow, `!=` for not-equal, straight quotes for curly ones, and the same for every
  other Unicode symbol. Applies everywhere, including this file.
- Comments justify *why*, not *what*. In these charts the *why* is usually the sharding/HA/storage
  rationale - keep those comments; delete any that just restate the YAML.
- Do not use the word "seam"; say boundary, interface, or extension point. Do not use "bespoke";
  say "custom".

## Commits

- Conventional Commits (see CONTRIBUTING.md). Subject in the present tense, imperative voice:
  `feat: add TLS values`, not `added` or `adds`.
- Mono-repo: scope chart-affecting commits with the chart name (`feat(bazelremote): ...`) once
  more than one chart exists; today the single chart also accepts unscoped commits.
- Keep the body minimal. Add body lines only for the non-obvious *why*. Do not restate the diff.
- Disclose AI with an `Assisted-by: Claude:claude-opus-4-8` trailer. Never `Co-Authored-By`, and
  never add a human's `Signed-off-by`.

## Chart conventions

- Every configurable value has a sane, public default in `values.yaml` with an inline comment,
  and a row in the chart README's values table.
- Never hardcode environment-specific infrastructure (registries, pull secrets, node selectors,
  storage classes, hostnames). Surface it as a value with a generic default; a chart must render
  and validate with defaults.
- The chart `version` and `CHANGELOG.md` are managed by knope; never bump them by hand. Bump
  `appVersion` by hand only when intentionally moving to a newer upstream release.
- Keep selector labels stable: changing a StatefulSet/Deployment `spec.selector` is a breaking,
  in-place-upgrade-hostile change.

## CI workflows

- GitHub Actions live in `.github/workflows`. Write the workflow `name:`, every job name, and
  every named step in Sentence case, matching `ci.yml` (e.g. `name: CI`, `Lint and validate charts`).
- Keep workflows minimal and scoped to one purpose; prefer the built-in `GITHUB_TOKEN` over a PAT.
