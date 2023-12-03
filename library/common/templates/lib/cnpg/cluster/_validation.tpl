{{- define "tc.v1.common.lib.cnpg.cluster.validation" -}}
  {{- $objectData := .objectData -}}

  {{- $requiredKeys := (list "database" "user") -}}
  {{- range $key := $requiredKeys -}}
    {{- if not (get $objectData $key) -}}
      {{- fail (printf "CNPG - Expected a non-empty [%s] key" $key) -}}
    {{- end -}}
  {{- end -}}

  {{- if (hasKey $objectData "version") -}}
    {{- $validVersions := (list "legacy") -}}
    {{- if not (mustHas $objectData.version $validVersions) -}}
      {{- fail (printf "CNPG - Expected [version] to be one of [%s], but got [%s]" (join ", " $validVersions) $objectData.version) -}}
    {{- end -}}
  {{- end -}}

  {{- if (hasKey $objectData "hibernate") -}}
    {{- if not (kindIs "bool" $objectData.hibernate) -}}
      {{- fail (printf "CNPG - Expected [hibernate] to be a boolean, but got [%s]" (kindOf $objectData.hibernate)) -}}
    {{- end -}}
  {{- end -}}

  {{- if (hasKey $objectData "mode") -}}
    {{- $validModes := (list "standalone" "replica" "recovery") -}}
    {{- if not (mustHas $objectData.mode $validModes) -}}
      {{- fail (printf "CNPG Cluster - Expected [mode] to be one of [%s], but got [%s]" (join ", " $validModes) $objectData.mode) -}}
    {{- end -}}
  {{- end -}}

  {{- if (hasKey $objectData "type") -}}
    {{- $validTypes := (list "postgresql" "postgis" "timescaledb") -}}
    {{- if not (mustHas $objectData.type $validTypes) -}}
      {{- fail (printf "CNPG Cluster - Expected [type] to be one of [%s], but got [%s]" (join ", " $validTypes) $objectData.type) -}}
    {{- end -}}
  {{- end -}}

  {{- if (hasKey $objectData "cluster") -}}
    {{- if (hasKey $objectData.cluster "logLevel") -}}
      {{- $validLevels := (list "error" "warning" "info" "debug" "trace") -}}
      {{- if not (mustHas $objectData.cluster.logLevel $validLevels) -}}
        {{- fail (printf "CNPG Cluster - Expected [cluster.logLevel] to be one of [%s], but got [%s]" (join ", " $validLevels) $objectData.cluster.logLevel) -}}
      {{- end -}}
    {{- end -}}

    {{- if (hasKey $objectData.cluster "primaryUpdateStrategy") -}}
      {{- $validStrategies := (list "supervised" "unsupervised") -}}
      {{- if not (mustHas $objectData.cluster.primaryUpdateStrategy $validStrategies) -}}
        {{- fail (printf "CNPG Cluster - Expected [cluster.primaryUpdateStrategy] to be one of [%s], but got [%s]" (join ", " $validStrategies) $objectData.cluster.primaryUpdateStrategy) -}}
      {{- end -}}
    {{- end -}}

    {{- if (hasKey $objectData.cluster "primaryUpdateMethod") -}}
      {{- $validMethods := (list "switchover" "restart") -}}
      {{- if not (mustHas $objectData.cluster.primaryUpdateMethod $validMethods) -}}
        {{- fail (printf "CNPG Cluster - Expected [cluster.primaryUpdateMethod] to be one of [%s], but got [%s]" (join ", " $validMethods) $objectData.cluster.primaryUpdateMethod) -}}
      {{- end -}}
    {{- end -}}

    {{- if (hasKey $objectData.cluster "initdb") -}}
      {{- with $objectData.cluster.initdb.walSegmentSize -}}
        {{- if not (mustHas (kindOf .) (list "int" "int64" "float64")) -}}
          {{- fail (printf "CNPG Cluster - Expected [cluster.initdb.walSegmentSize] to be an integer, but got [%s]" (kindOf .)) -}}
        {{- end -}}
        {{- if or (lt (. | int) 1) (gt (. | int) 1024) -}}
          {{- fail (printf "CNPG Cluster - Expected [cluster.initdb.walSegmentSize] to be between 1 and 1024, but got [%d]" (. | int)) -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- if eq $objectData.mode "recovery" -}}
    {{- if not $objectData.recovery -}}
      {{- fail "CNPG Recovery - Expected a non-empty [recovery] key" -}}
    {{- end -}}

    {{- $validMethods := (list "backup" "object_store" "pg_basebackup") -}}
    {{- if not (mustHas $objectData.recovery.method $validMethods) -}}
      {{- fail (printf "CNPG Recovery - Expected [recovery.method] to be one of [%s], but got [%s]" (join ", " $validMethods) $objectData.recovery.method) -}}
    {{- end -}}
    {{- if eq $objectData.recovery.method "backup" -}}
      {{- if not $objectData.recovery.backupName -}}
        {{- fail "CNPG Recovery - Expected a non-empty [recovery.backupName] key" -}}
      {{- end -}}
    {{- else if eq $objectData.recovery.method "object_store" -}}
      {{- if not $objectData.recovery.serverName -}}
        {{- fail "CNPG Recovery - Expected a non-empty [recovery.serverName] key" -}}
      {{- end -}}
    {{- end -}}

  {{- end -}}

{{- end -}}
