# authentik-remote-cluster

This directory deploys the `authentik-remote-cluster` Helm chart into the `security` namespace.

The chart creates the Kubernetes RBAC resources that allow an authentik instance to connect to this cluster as a remote cluster. In this repository, the deployment enables:

- a service account credential secret (`serviceAccountSecret.enabled: true`)
- a cluster-wide role binding for authentik (`clusterRole.enabled: true`)

## Purpose

Use this chart on a cluster that should be managed or accessed by authentik as a remote cluster.

Typical use cases:

- Kubernetes integration in authentik
- granting controlled access to cluster resources through authentik
- managing more than one cluster from a central authentik instance

## Add the Cluster in authentik

After the chart is deployed successfully, generate a kubeconfig from the created service account and add that kubeconfig in authentik.

The easiest option in this repository is the shared task file:

```bash
task authentik:kubeconfig cluster=<cluster>
```

This renders the kubeconfig with `envsubst` and prints it to stdout so it can be copied directly into authentik.

You can override the defaults if needed:

```bash
task authentik:kubeconfig cluster=<cluster> ns=security release_name=authentik-remote-cluster
```

If you prefer to generate it manually, run the following commands against the remote cluster:

```bash
KUBE_API=$(kubectl config view --minify --output jsonpath="{.clusters[*].cluster.server}")
NAMESPACE=security
SECRET_NAME=$(kubectl get serviceaccount authentik-remote-cluster -n $NAMESPACE -o jsonpath='{.secrets[0].name}' 2>/dev/null || echo -n "authentik-remote-cluster")
KUBE_CA=$(kubectl -n $NAMESPACE get secret/$SECRET_NAME -o jsonpath='{.data.ca\.crt}')
KUBE_TOKEN=$(kubectl -n $NAMESPACE get secret/$SECRET_NAME -o jsonpath='{.data.token}' | base64 --decode)

cat <<EOF
apiVersion: v1
kind: Config
clusters:
  - name: default-cluster
    cluster:
      certificate-authority-data: ${KUBE_CA}
      server: ${KUBE_API}
contexts:
  - name: default-context
    context:
      cluster: default-cluster
      namespace: ${NAMESPACE}
      user: authentik-user
current-context: default-context
users:
  - name: authentik-user
    user:
      token: ${KUBE_TOKEN}
EOF
```

Copy the generated kubeconfig output and then add the remote cluster in authentik.

Suggested authentik flow:

1. Open authentik as an administrator.
2. Go to the section for Kubernetes or remote cluster integrations. (System -> Outpost integrations)
3. Create a new remote cluster entry.
4. Paste the generated kubeconfig.
5. Save the configuration and verify the connection.

