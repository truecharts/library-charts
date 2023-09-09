{{- define "tc.v1.common.lib.cnpg.spawner.backup" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}

  {{- $validProviders := (list "azure" "google" "object_store" "s3") -}}
  {{- $provider := $objectData.backups.provider -}}
  {{- if not (mustHas $provider $validProviders) -}}
    {{- fail (printf "CNPG - Expected <backups.provider> to be one of [%s], but got [%s]" (join ", " $validProviders) $provider) -}}
  {{- end -}}

  {{- $creds := (get $objectData.backup $provider) -}}
  {{- with (include (printf "tc.v1.common.lib.cnpg.secret.%s" $provider) (dict "creds" $creds) | fromYaml) -}}
    {{- $_ := set $.Values.secret (printf "%s-backup-%s-creds" $objectData.shortName $provider) . -}}
  {{- end -}}
{{- end -}}
