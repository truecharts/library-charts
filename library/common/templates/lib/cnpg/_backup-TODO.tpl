{{- define "tc.v1.common.lib.cnpg.backup.secret" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}

  {{- $creds := (get $objectData.backup $objectData.backups.provider) -}}
  {{- with (include (printf "tc.v1.common.lib.cnpg.secret.%s" $objectData.backups.provider) (dict "creds" $creds) | fromYaml) -}}
    {{- $_ := set $.Values.secret (printf "%s-backup-%s-creds" $objectData.shortName $objectData.backups.provider) . -}}
  {{- end -}}
{{- end -}}
