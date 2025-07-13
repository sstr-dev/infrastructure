## 📘 KubeBlocks v0.9.3 – Manual Installation Guide (with CRD Fix)

This guide installs [KubeBlocks](https://kubeblocks.io) v0.9.3 on a Kubernetes cluster using **manual CRD setup** due to Kubernetes annotation size limitations. It includes:

* Downloading and preparing CRDs
* Cleaning up oversized fields
* Splitting the apply into safe chunks
* Installing the KubeBlocks Helm chart

---

### ✅ Prerequisites

* Kubernetes cluster (`kubectl` configured with context)
* [yq v4+](https://github.com/mikefarah/yq)
* [Helm](https://helm.sh)

---

## 🔧 1. Download the CRD Bundle

```bash
curl -LO https://github.com/apecloud/kubeblocks/releases/download/v0.9.3/kubeblocks_crds.yaml
```

---

## 🧹 2. Remove `metadata.annotations` from bulk CRDs

```bash
yq 'del(.items[].metadata.annotations)' -i kubeblocks_crds.yaml
```

---

## 🧪 3. Apply the “small” CRDs (these won’t exceed the annotation limit)

```bash
kubectl apply --context <your-context> -f kubeblocks_crds.yaml
```

⚠️ This will fail only on the **7 large CRDs** — that's expected.

---

## ✂️ 4. Extract the oversized CRDs for special handling

```bash
yq -o yaml '.items[] | select(
  .metadata.name == "clusterdefinitions.apps.kubeblocks.io" or
  .metadata.name == "clusters.apps.kubeblocks.io" or
  .metadata.name == "componentdefinitions.apps.kubeblocks.io" or
  .metadata.name == "components.apps.kubeblocks.io" or
  .metadata.name == "opsdefinitions.apps.kubeblocks.io" or
  .metadata.name == "opsrequests.apps.kubeblocks.io" or
  .metadata.name == "instancesets.workloads.kubeblocks.io"
)' kubeblocks_crds.yaml | yq -s '.' > kubeblocks_crds_stripped.yaml
```

---

## 🪒 5. Remove all nested `description` and `annotations` fields

```bash
yq eval '
  del(.[] | .metadata.annotations) |
  del(.[] | .spec.versions[].schema.openAPIV3Schema.description) |
  del(.[] | .. | select(has("description")).description)
' -i kubeblocks_crds_stripped.yaml
```

---

## 🚀 6. Apply the stripped CRDs

```bash
kubectl apply --context <your-context> -f kubeblocks_crds_stripped.yaml
```

You should see success for all remaining CRDs:

```bash
customresourcedefinition.apiextensions.k8s.io/clusterdefinitions.apps.kubeblocks.io created
```

---

## ✅ Done!

You now have **all KubeBlocks CRDs** properly installed, even the large ones that exceeded Kubernetes annotation size limits.

You can verify CRD presence with:

```bash
kubectl get crds | grep kubeblocks
```

