{{- define "tc.v1.common.lib.velero.provider.aws.secret" -}}
  {{- $creds := .creds -}}

  {{- $reqKeys := list "id" "key" -}}
  {{- range $k := $reqKeys -}}
    {{- if not (get $creds $k) -}}
      {{- fail (printf "Volume Snapshot Location - Expected non-empty [credential.aws.%s] for [aws] provider" $k) -}}
    {{- end -}}
  {{- end }}
data: |
  [default]
  aws_access_key_id={{ $creds.id }}
  aws_secret_access_key={{ $creds.key }}
{{- end -}}
