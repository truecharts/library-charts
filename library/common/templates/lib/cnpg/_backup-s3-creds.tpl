{{- define "tc.v1.common.lib.cnpg.secret.s3" -}}
enabled: true
data:
  ACCESS_KEY_ID: {{ .accessKey | quote }}
  ACCESS_SECRET_KEY: {{ .secretKey | quote }}
{{- end -}}
