# Namespace: `dev`

This namespace contains development services and supporting tooling.

## Components

| Application                         | Description                                     | Links                                                                                                      | Notes                                                                  |
|-------------------------------------|-------------------------------------------------|------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------|
| [harbor](./harbor/)                 | OCI registry for container images and artifacts | [Vendor](https://goharbor.io/) [GitHub](https://github.com/goharbor/harbor)                                | Exposed at `registry.${SECRET_DEV_DOMAIN}`                             |
| [forgejo](./forgejo/)               | Self-hosted Git service and web UI              | [Vendor](https://forgejo.org/) [GitHub](https://codeberg.org/forgejo/forgejo)                              | Exposes HTTP through `HTTPRoute`, and provides SSH via `LoadBalancer`. |
| [forgejo-runner](./forgejo-runner/) | Self-hosted Forgejo Actions runner              | [Vendor](https://forgejo.org/docs/latest/admin/actions/) [GitHub](https://code.forgejo.org/forgejo/runner) | Depends on Forgejo and runs Actions jobs with Docker-in-Docker.        |
