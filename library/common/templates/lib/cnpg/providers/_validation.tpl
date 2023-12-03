{{- define "tc.v1.common.lib.cnpg.provider.validation" -}}
  {{- $objectData := .objectData -}}
  {{- $provider := $objectData.backups.provider -}}

  {{- $validProviders := (list "azure" "s3" "google") -}}
  {{- if not (mustHas $provider $validProviders) -}}
    {{- fail (printf "CNPG Backup - Expected [backups.provider] to be one of [%s], but got [%s]" (join ", " $validProviders) $provider) -}}
  {{- end -}}

  {{- if not (get $objectData.backups $provider) -}}
    {{- fail (printf "CNPG Backup - Expected [backups.%s] to be defined when [backups.provider] is set to [%s]" $provider $provider) -}}
  {{- end -}}

{{- end -}}
