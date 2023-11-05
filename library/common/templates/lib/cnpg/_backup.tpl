{{- define "tc.v1.common.lib.cnpg.spawner.backup" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}

  {{- $creds := (get $objectData.backup $provider) -}}
  {{- with (include (printf "tc.v1.common.lib.cnpg.secret.%s" $provider) (dict "creds" $creds) | fromYaml) -}}
    {{- $_ := set $.Values.secret (printf "%s-backup-%s-creds" $objectData.shortName $provider) . -}}
  {{- end -}}
{{- end -}}
