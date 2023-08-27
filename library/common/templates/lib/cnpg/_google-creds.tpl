{{- define "tc.v1.common.lib.cnpg.secret.google" -}}
{{- $creds := .creds -}}
{{- $reqKeys := (list "applicationCredentials") -}}
{{- range $r := $reqKeys -}}
  {{- if get $creds $r -}}
    {{- fail (printf "CNPG - Google Creds requires [%s] to be defined and non-empty" $r) -}}
  {{- end -}}
{{- end }}
enabled: true
data:
  APPLICATION_CREDENTIALS: {{ $creds.applicationCredentials | quote }}
{{- end -}}
