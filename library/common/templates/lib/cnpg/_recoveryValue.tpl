{{- define "tc.v1.common.lib.cnpg.configmap.recoverystring" -}}
enabled: true
data:
  recoverystring: {{ .recoverystring | quote }}
{{- end -}}
