# Step-by-Step Guide: Configuring Prometheus Alertmanager with Slack

This guide walks you through setting up **Slack alerts** from **Prometheus Alertmanager**, including creating a Slack app with Incoming Webhook integration and configuring Alertmanager to send formatted alerts to a Slack channel.

---

## ✨ Prerequisites

- A running Prometheus and Alertmanager setup.
- A Slack workspace (you can create a free one for testing).
- Permissions to install Slack apps in your workspace.

---

## 🏢 Step 1: Set Up Incoming Webhook in Slack

1. **Open your Slack workspace.**
2. Go to **Administration > Manage Apps**.
3. In the Apps directory, search for **"Incoming WebHooks"**.
4. Click **Add to Slack**.
5. Choose the **channel** where alerts should be sent (can be private or public).
6. Click **Add Incoming WebHooks integration**.
7. Copy the generated **Webhook URL** (e.g., `https://hooks.slack.com/services/T000/B000/XXXX`).

---

## 📎 Step 2: Configure Alertmanager to Use the Webhook

You can configure Alertmanager by editing the existing **Secret** that stores the Alertmanager config.

### 🔍 Find Alertmanager Secret
```bash
kubectl get secret -n observability | grep alertmanager
k get secret alertmanager-kube-prom-stack-kube-prome-alertmanager -o yaml
```

Usually it's called `alertmanager-kube-prometheus-stack-alertmanager`.

### 🔧 Extract and Edit Configuration
```bash
kubectl get secret alertmanager-kube-prom-stack-kube-prome-alertmanager \
  -n observability -o jsonpath="{.data.alertmanager\.yaml}" | base64 -d > alertmanager.yaml
```

Edit `alertmanager.yaml`:
```yaml
global:
  resolve_timeout: 5m
inhibit_rules:
- equal:
  - namespace
  - alertname
  source_matchers:
  - severity = critical
  target_matchers:
  - severity =~ warning|info
- equal:
  - namespace
  - alertname
  source_matchers:
  - severity = warning
  target_matchers:
  - severity = info
- equal:
  - namespace
  source_matchers:
  - alertname = InfoInhibitor
  target_matchers:
  - severity = info
receivers:
- name: "null"
- name: 'slack-notification'
  slack_configs:
      - api_url: 'https://hooks.slack.com/services/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'
        channel: '#devesecops-engineering-pilot-class'
        send_resolved: true
        title: '{{ .CommonLabels.alertname }} - {{ .Status }}'
        text: '{{ .CommonAnnotations.description }}'
route:
  group_by:
  - namespace
  group_interval: 5m
  group_wait: 30s
  receiver: "null"
  repeat_interval: 12h
  routes:
  - matchers:
    - alertname =~ "InfoInhibitor|Watchdog"
    receiver: "null"
  - match:
      alert: 'slack'
    receiver: 'slack-notification'

templates:
- /etc/alertmanager/config/*.tmpl
```

> Replace `#your-channel` with your channel name, or use the **channel ID** if it's private.

---

### 🔄 Update the Secret and Restart Alertmanager

```bash
kubectl create secret generic alertmanager-kube-prom-stack-kube-prome-alertmanager \
  --from-file=alertmanager.yaml=alertmanager.yaml \
  -n observability --dry-run=client -o yaml | kubectl apply -f -

kubectl delete pod -l app.kubernetes.io/name=alertmanager -n observability
```

---

## 🚀 Step 3: Trigger a Test Alert (Optional)

Create a test alert rule with `alert: slack` label:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: important-pod-crash-alert
  namespace: observability
  labels:
    release: kube-prom-stack
spec:
  groups:
  - name: important-pod.rules
    rules:
    - alert: ImportantPodCrashLoopBackOffOrError
      expr: |
        max_over_time(
          kube_pod_container_status_waiting_reason{pod=~"important-pod.*", reason=~"CrashLoopBackOff|Error"}[5m]
        ) >= 1
      for: 30s
      labels:
        severity: critical
        alert: slack
      annotations:
        summary: "Important pod is crashing or in error state"
        description: "Pod '{{ $labels.pod }}' in namespace '{{ $labels.namespace }}' is in {{ $labels.reason }} state for more than 30 seconds."

```

Apply it:
```bash
kubectl apply -f test-alert.yaml
```

---

## ✉️ Notes
- `send_resolved: true` is **required** to get resolved alerts in Slack.
- Resolved messages may be delayed by `group_interval`.
- Use `kubectl logs` on the Alertmanager pod to debug alert delivery.

---

## 🚀 Want More?
- Add PagerDuty or Gmail as additional receivers.
- Customize Slack formatting with Alertmanager templates.
- Integrate ZAP, Juice Shop, and automate security alerts.

---

> With this setup, you're ready to receive clean, formatted alerts in Slack from Prometheus Alertmanager — whether it's infra crashes, high CPU, or custom security scans.
