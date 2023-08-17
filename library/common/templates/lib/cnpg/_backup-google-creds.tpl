{{- define "tc.v1.common.lib.cnpg.secret.google" -}}
enabled: true
data:
  APPLICATION_CREDENTIALS: {{ .applicationCredentials  | quote }}
{{- end -}}
