# Security Policy

## Reporting a vulnerability

Please report suspected vulnerabilities privately, not as a public issue. Use
GitHub's private vulnerability reporting for this repository (the "Security" tab
-> "Report a vulnerability"). Include the chart, the affected version, and
reproduction steps (values and rendered manifests help). We aim to acknowledge
within a few days and will keep you posted on remediation.

## Scope

These are deployment charts; the applications they deploy are upstream projects
with their own security policies (e.g. report bazel-remote issues to
[buchgr/bazel-remote](https://github.com/buchgr/bazel-remote)). In scope here:
chart defaults or templates that produce an insecure manifest, leak a secret, or
grant more privilege than documented.

Note that the `bazelremote` chart deploys bazel-remote as an **unauthenticated,
shared cache** by default and, when `ingress.enabled=true`, serves over plain
HTTP unless the ingress terminates TLS. That is the documented model for a
locked-down build network - restrict who can reach the Service/Ingress and treat
reachability as read/write access to the cache. Documented behavior like this is
not a vulnerability on its own; reports that contradict or extend the documented
model are.

## Supported versions

Pre-1.0: fixes land on the latest published release of the affected chart.
