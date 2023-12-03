{{- define "tc.v1.common.lib.cnpg.provider.secret.spawner" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $type := .type -}}

  {{- if not $type -}}
    {{- fail "CNPG Provider Secret Spawner - No [type] was given" -}}
  {{- end -}}

  {{- $provider := $objectData.backups.provider -}}
  {{/* Get the creds defined in backup.$provider */}}
  {{- $creds := (get $objectData.backups $provider) -}}

  {{- include "tc.v1.common.lib.cnpg.provider.validation" (dict "objectData" $objectData) -}}
  {{- include (printf "tc.v1.common.lib.cnpg.provider.%s.validation" $provider) (dict "objectData" $objectData "creds" $creds) -}}
  {{- with (include (printf "tc.v1.common.lib.cnpg.provider.%s.secret" $provider) (dict "creds" $creds) | fromYaml) -}}
    {{- $_ := set $rootCtx.Values.secret (printf "cnpg-%s-provider-%s-%s-creds" $objectData.shortName $type $provider) . -}}
  {{- end -}}
{{- end -}}
