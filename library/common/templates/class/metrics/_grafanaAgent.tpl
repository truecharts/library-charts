{{- define "tc.v1.common.class.metrics.grafanaagent" -}}
  {{- $fullName := include "tc.v1.common.lib.chart.names.fullname" . -}}
  {{- $grafanaagentName := $fullName -}}
  {{- $values := .Values.grafanaagent -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.metrics -}}
      {{- $values = . -}}
    {{- end -}}
  {{- end -}}
  {{- $grafanaagentLabels := $values.labels -}}
  {{- $grafanaagentAnnotations := $values.annotations -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $grafanaagentName = printf "%v-%v" $grafanaagentName $values.nameOverride -}}
  {{- end }}

  {{- include "tc.v1.common.lib.util.verifycrd" (dict "crd" "grafanaagents.monitoring.grafana.com" "missing" "Grafana-Agent-Operator") }}

---
apiVersion: monitoring.grafana.com/v1alpha1
kind: GrafanaAgent
metadata:
  name: {{ $grafanaagentName }}
  namespace: {{ $.Values.namespace | default $.Values.global.namespace | default $.Release.Namespace }}
  {{- $labels := (mustMerge ($grafanaagentLabels | default dict) (include "tc.v1.common.lib.metadata.allLabels" $ | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $ "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end }}
  {{- $annotations := (mustMerge ($grafanaagentAnnotations | default dict) (include "tc.v1.common.lib.metadata.allAnnotations" $ | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $ "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
spec:
  containers:
    - name: config-reloader
    - name: grafana-agent
  disableReporting: false
  disableSupportBundle: false
  enableConfigReadAPI: false
  logs:
    instanceSelector:
      matchLabels:
        app.kubernetes.io/component: meta-monitoring
        app.kubernetes.io/instance: mimir
        app.kubernetes.io/name: mimir
  metrics:
    externalLabels:
      cluster: mimir
    instanceSelector:
      matchLabels:
        app.kubernetes.io/component: meta-monitoring
        app.kubernetes.io/instance: mimir
        app.kubernetes.io/name: mimir
    scrapeInterval: 60s
  serviceAccountName: mimir
{{- end -}}
