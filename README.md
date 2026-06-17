# image-build-calico-whisker

This repo builds the hardened Calico Whisker UI from
[github.com/projectcalico/calico](https://github.com/projectcalico/calico) (the `whisker`
frontend) and serves the compiled static assets with nginx on a minimal SLE BCI
(`registry.suse.com/bci/bci-base`) base image.

The frontend is compiled with the SLE BCI Node.js builder image. Unlike the pure-Go
components, Whisker is a static web app, so `bci-base` (with nginx) is used rather than
`bci-nano`.

## Images produced

- `cwayne18/hardened-calico-whisker` — Calico Whisker UI

## Building locally

```sh
make build-image-all          # build for the host architecture
make image-scan               # run Trivy against the built image(s)
```

The upstream version is controlled by the `TAG` variable in the [`Makefile`](./Makefile).
A `-buildYYYYMMDD` suffix (`BUILD_META`) is appended automatically and is required on
release tags.

## Automated updates

[Updatecli](./updatecli) bumps the upstream Calico version (`Makefile` `TAG`) via daily PRs.

## CI

- **Build**: builds the image and runs a [Trivy](https://github.com/aquasecurity/trivy) scan
  (`CRITICAL,HIGH`) on every PR/push.
- **Release**: on a published GitHub release, builds multi-arch images and pushes them to
  `ghcr.io/cwayne18`.
