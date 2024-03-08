{{- define "tc.v1.common.lib.cnpg.configmap.pgversion" -}}
{{- $major := .major -}}
enabled: true
data:
  major: {{ $major }}
{{- end -}}
