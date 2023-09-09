{{- define "tc.v1.common.lib.cnpg.spawner.recovery.objectStore" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}

  {{- $validMethods := (list "object_store" "backup" "pg_basebackup") -}}
  {{- if and $objectData.recovery.method (not (mustHas $objectData.recovery.method $validMethods)) -}}
    {{- fail (printf "CNPG - Expected <recovery.method> to be one of [%s], but got [%s]" (join ", " $validMethods) $objectData.recovery.method) -}}
  {{- end -}}

  {{- if and (eq $objectData.mode "recovery") (eq $objectData.recovery.method "object_store") -}}
    {{- $validProviders := (list "azure" "google" "object_store" "s3") -}}
    {{- $provider := $objectData.recovery.provider -}}
    {{- if not (mustHas $provider $validProviders) -}}
      {{- fail (printf "CNPG - Expected <recovery.provider> to be one of [%s], but got [%s]" (join ", " $validProviders) $provider) -}}
    {{- end -}}

    {{- $creds := (get $objectData.recovery $provider) -}}
    {{- with (include (printf "tc.v1.common.lib.cnpg.secret.%s" $provider) (dict "creds" $creds) | fromYaml) -}}
      {{- $_ := set $.Values.secret (printf "%s-recovery-%s-creds" $objectData.shortName $provider) . -}}
    {{- end -}}

  {{- end -}}
{{- end -}}
