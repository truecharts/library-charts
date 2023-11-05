{{- define "tc.v1.common.lib.cnpg.validation" -}}
  {{- $objectData := .objectData -}}

  {{- $validTypes := (list "postgresql" "postgis" "timescaledb") -}}
  {{- if not (mustHas $objectData.type $validTypes) -}}
    {{- fail (printf "CNPG - Expected [type] to be one of [%s], but got [%s]" (join ", " $validTypes) $objectData.mode) -}}
  {{- end -}}

  {{- $validModes := (list "standalone" "replica" "recovery") -}}
  {{- if not (mustHas $objectData.mode $validModes) -}}
    {{- fail (printf "CNPG - Expected [mode] to be one of [%s], but got [%s]" (join ", " $validModes) $objectData.mode) -}}
  {{- end -}}

  {{- $requiredKeys := (list "database" "user" "password") -}}
  {{- range $key := $requiredKeys -}}
    {{- if not (get $objectData $key) -}}
      {{- fail (printf "CNPG - Expected a non empty [%s] key") -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "tc.v1.common.lib.cnpg.cluster.recovery.validation" -}}
  {{- $objectData := .objectData -}}

  {{- if not (hasKey $objectData "recovery") -}}
    {{- fail "CNPG Cluster Recovery - Expected [recovery] key to exist" -}}
  {{- end -}}

  {{- $validMethods := (list "backup" "object_store") -}}
  {{- if not (mustHas $objectData.recovery.method $validMethods) -}}
    {{- fail (printf "CNPG Cluster Recovery  - Expected [method] to be one of [%s], but got [%s]" (join ", " $validMethods) $objectData.recovery.method) -}}
  {{- end -}}

  {{- if eq $objectData.recovery.method "backup" -}}
    {{- if not $objectData.recovery.backupName -}}
      {{- fail "CNPG Cluster Recovery - Expected non empty [backupName] key" -}}
    {{- end -}}
  {{- end -}}

  {{- if eq $objectData.recovery.method "object_store" -}}
    {{- if not $objectData.recovery.serverName -}}
      {{- fail "CNPG Cluster Recovery - Expected non empty [serverName] key" -}}
    {{- end -}}
  {{- end -}}

{{- end -}}

{{- define "tc.v1.common.lib.cnpg.pooler.validation" -}}
  {{- $objectData := .objectData -}}

  {{- $validTypes := (list "rw" "ro") -}}
  {{- if not (mustHas $objectData.pooler.type $validTypes) -}}
    {{- fail (printf "CNPG Pooler - Expected pooler [type] to be one one of [%s], but got [%s]" (join ", " $validTypes) $objectData.pooler.type) -}}
  {{- end -}}

  {{- $validPgModes := (list "session" "transaction") -}}
  {{- if $objectData.pooler.poolMode -}}
    {{- if not (mustHas $objectData.pooler.poolMode $validPgModes) -}}
      {{- fail (printf "CNPG Pooler - Expected pooler [poolMode] to be one one of [%s], but got [%s]" (join ", " $validPgModes) $objectData.pooler.poolMode) -}}
    {{- end -}}
  {{- end  -}}
{{- end -}}
