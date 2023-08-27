{{- define "tc.v1.common.lib.cnpg.secret.urls" -}}
{{- $creds := .creds }}
enabled: true
data:
  std: {{ $creds.std }}
  nossl: {{ $creds.nossl }}
  porthost: {{ $creds.porthost }}
  host: {{ $creds.host }}
  jdbc: {{ $creds.jdbc }}
{{- end -}}
