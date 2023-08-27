{{- define "tc.v1.common.lib.cnpg.secret.s3" -}}
{{- $creds := .creds -}}
{{- $reqKeys := (list "accessKey" "secretKey") -}}
{{- range $r := $reqKeys -}}
  {{- if get $creds $r -}}
    {{- fail (printf "CNPG - S3 Creds requires [%s] to be defined and non-empty" $r) -}}
  {{- end -}}
{{- end }}
enabled: true
data:
  ACCESS_KEY_ID: {{ $creds.accessKey | quote }}
  ACCESS_SECRET_KEY: {{ $creds.secretKey | quote }}
{{- end -}}
