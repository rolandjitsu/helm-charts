**What kind of change does this PR introduce?**
- [ ] fix
- [ ] feat
- [ ] refactor
- [ ] docs
- [ ] build / ci
- [ ] chore

**Which chart(s)?**
e.g. `bazelremote`

**Summary**
Explain the motivation. What problem does this solve? Link any related issue.

**Checklist**
- [ ] `helm lint charts/<chart>` passes
- [ ] `helm template ... | kubeconform -strict -ignore-missing-schemas` passes (including
      `--set ingress.enabled=true --set storage.createStorageClass=true`)
- [ ] New/changed values are documented in `values.yaml` (inline) and the chart README table
- [ ] No environment-specific infrastructure hardcoded (registry, pull secrets, node selector,
      storage class, hostname) - all surfaced as values with generic defaults
- [ ] `appVersion` bumped only if intentionally tracking a new upstream release (chart `version`
      and CHANGELOG are handled by knope - do not edit by hand)
- [ ] Commits follow Conventional Commits; AI-assisted commits carry an `Assisted-by:` trailer

**Breaking change?**
If yes, describe the impact and the migration path (renamed/removed values, changed selectors,
default changes).
