{{- define "tc.v1.common.lib.velero.provider.aws.secret" -}}
  {{- $creds := .creds }}
data: |
  [default]
  aws_access_key_id={{ $creds.id }}
  aws_secret_access_key={{ $creds.key }}
{{- end -}}
