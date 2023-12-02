{{- define "tc.v1.common.lib.cnpg.validation" -}}
  {{- $objectData := .objectData -}}

  {{- $validTypes := (list "postgresql" "postgis" "timescaledb") -}}
  {{- if not (mustHas $objectData.type $validTypes) -}}
    {{- fail (printf "CNPG - Expected [type] to be one of [%s], but got [%s]" (join ", " $validTypes) $objectData.type) -}}
  {{- end -}}

  {{- $validModes := (list "standalone" "replica" "recovery") -}}
  {{- if not (mustHas $objectData.mode $validModes) -}}
    {{- fail (printf "CNPG - Expected [mode] to be one of [%s], but got [%s]" (join ", " $validModes) $objectData.mode) -}}
  {{- end -}}

  {{- $requiredKeys := (list "database" "user") -}}
  {{- range $key := $requiredKeys -}}
    {{- if not (get $objectData $key) -}}
      {{- fail (printf "CNPG - Expected a non-empty [%s] key" $key) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "tc.v1.common.lib.cnpg.cluster.recovery.validation" -}}
  {{- $objectData := .objectData -}}

  {{- $validMethods := (list "backup" "object_store" "pg_basebackup") -}}
  {{- if not (mustHas $objectData.recovery.method $validMethods) -}}
    {{- fail (printf "CNPG Cluster Recovery - Expected [method] to be one of [%s], but got [%s]" (join ", " $validMethods) $objectData.recovery.method) -}}
  {{- end -}}

  {{- if eq $objectData.recovery.method "backup" -}}
    {{- if not $objectData.recovery.backupName -}}
      {{- fail "CNPG Cluster Recovery - Expected non-empty [backupName] key when [method] is [backup]" -}}
    {{- end -}}
  {{- end -}}

  {{- if eq $objectData.recovery.method "object_store" -}}
    {{- if not $objectData.recovery.serverName -}}
      {{- fail "CNPG Cluster Recovery - Expected non-empty [serverName] key when [method] is [object_store]" -}}
    {{- end -}}
  {{- end -}}

{{- end -}}

{{- define "tc.v1.common.lib.cnpg.pooler.validation" -}}
  {{- $objectData := .objectData -}}

  {{- $validTypes := (list "rw" "ro") -}}
  {{- if not (mustHas $objectData.pooler.type $validTypes) -}}
    {{- fail (printf "CNPG Pooler - Expected [type] to be one one of [%s], but got [%s]" (join ", " $validTypes) $objectData.pooler.type) -}}
  {{- end -}}

  {{- $validPgModes := (list "session" "transaction") -}}
  {{- if $objectData.pooler.poolMode -}}
    {{- if not (mustHas $objectData.pooler.poolMode $validPgModes) -}}
      {{- fail (printf "CNPG Pooler - Expected [poolMode] to be one of [%s], but got [%s]" (join ", " $validPgModes) $objectData.pooler.poolMode) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "tc.v1.common.lib.cnpg.cluster.backup.validation" -}}
  {{- $objectData := .objectData -}}

  {{- if $objectData.backups.enabled -}}
    {{- $validProviders := (list "azure" "google" "object_store" "s3") -}}
    {{- if not (mustHas $objectData.backups.provider $validProviders) -}}
      {{- fail (printf "CNPG Backup - Expected [backups.provider] to be one of [%s], but got [%s]" (join ", " $validProviders) $objectData.backups.provider) -}}
    {{- end -}}

    {{- $regexPolicy := "^[1-9][0-9]*[dwm]$" -}} {{/* Copied from upstream */}}
    {{- if not (mustRegexMatch $regexPolicy $objectData.backups.retentionPolicy) -}}
      {{- fail (printf "CNPG Backup - Expected [backups.retentionPolicy] to match regex [%s], got [%s]" $regexPolicy $objectData.backups.retentionPolicy) -}}
    {{- end -}}

    {{- $validTargets := (list "primary" "prefer-standby") -}}
    {{- if not (mustHas $objectData.backups.target $validTargets) -}}
      {{- fail (printf "CNPG Backup - Expected [backups.target] to be one of [%s], but got [%s]" (join ", " $validTargets) $objectData.backups.target) -}}
    {{- end -}}

  {{- end -}}
{{- end -}}

{{- define "tc.v1.common.lib.cnpg.backup.validation.old" -}}
  {{- $objectData := .objectData -}}

  {{- if not $objectData.schedData.name -}}
    {{- fail "CNPG Scheduled Backups - Expected non-empty [name]" -}}
  {{- end -}}

  {{- if not $objectData.schedData.schedule -}}
    {{- fail "CNPG Scheduled Backups - Expected non-empty [schedule]" -}}
  {{- end -}}

  {{- if not $objectData.schedData.backupOwnerReference -}}
    {{- fail "CNPG Scheduled Backups - Expected non-empty [backupOwnerReference]" -}}
  {{- end -}}

{{- end -}}

{{- define "tc.v1.common.lib.cnpg.cluster.validation" -}}
  {{- $objectData := .objectData -}}

  {{- if $objectData.cluster.primaryUpdateStrategy -}}
    {{- $validStrategies := (list "unsupervised" "supervised") -}}
    {{- if not (mustHas $objectData.cluster.primaryUpdateStrategy $validStrategies) -}}
      {{- fail (printf "CNPG Cluster - Expected [cluster.primaryUpdateStrategy] to be one of [%s], but got [%s]" (join ", " $validStrategies) $objectData.cluster.primaryUpdateStrategy) -}}
    {{- end -}}
  {{- end -}}

  {{- if $objectData.cluster.primaryUpdateMethod -}}
    {{- $validMethods := (list "switchover" "restart") -}}
    {{- if not (mustHas $objectData.cluster.primaryUpdateMethod $validMethods) -}}
      {{- fail (printf "CNPG Cluster - Expected [cluster.primaryUpdateMethod] to be one of [%s], but got [%s]" (join ", " $validMethods) $objectData.cluster.primaryUpdateStrategy) -}}
    {{- end -}}
  {{- end -}}

{{- end -}}
