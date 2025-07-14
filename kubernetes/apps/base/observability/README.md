# 🗂️ Namespace: `observability`

This namespace contains applications and components responsible for monitoring, alerting, and telemetry collection across the Kubernetes cluster.

---

## 📦 Included Components

| Application                                           | Description                                                | Links                                                                       |
|-------------------------------------------------------|------------------------------------------------------------|-----------------------------------------------------------------------------|
| [**exporters**](./exporters/)                         | Exporters for metrics (node, blackbox, etc.)               | [Prometheus Exporters](https://prometheus.io/docs/instrumenting/exporters/) |
| [**gatus**](./gatus/)                                 | Uptime monitoring & status page tool                       | [Website](https://gatus.io) [GitHub](https://github.com/TwiN/gatus)         |
| [**grafana**](./grafana/)                             | Dashboards & visualization platform for observability      | [Website](https://grafana.com) [GitHub](https://github.com/grafana/grafana) |
| [**kube-prometheus-stack**](./kube-prometheus-stack/) | Complete monitoring stack (Prometheus, Alertmanager, etc.) | [Docs](https://github.com/prometheus-operator/kube-prometheus)              |

---

## 📎 Notes

- This stack powers metrics, alerting, service monitoring, and dashboards.
- Exporters collect data for hardware, endpoints, and protocols.
- Grafana is pre-integrated with Prometheus as a datasource.
