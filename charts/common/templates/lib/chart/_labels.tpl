{{/* Common labels shared across objects */}}
{{- define "tc.common.v10.labels" -}}
helm.sh/chart: {{ include "tc.common.v10.names.chart" . }}
{{ include "tc.common.v10.labels.selectorLabels" . }}
  {{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
  {{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
  {{- with .Values.global.labels }}
    {{- range $k, $v := . }}
      {{- $name := $k }}
      {{- $value := tpl $v $ }}
{{ $name }}: {{ quote $value }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/* Selector labels shared across objects */}}
{{- define "tc.common.v10.labels.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tc.common.v10.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
