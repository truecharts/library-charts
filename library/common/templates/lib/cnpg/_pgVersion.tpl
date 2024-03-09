{{- define "tc.v1.common.lib.cnpg.configmap.pgVersion" -}}
  {{- $major := .major }}
enabled: true
data:
  major: {{ $major | quote }}
{{- end -}}
