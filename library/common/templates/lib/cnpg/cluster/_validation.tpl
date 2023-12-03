{{- define "tc.v1.common.lib.cnpg.cluster.validation" -}}
  {{- $objectData := .objectData -}}

  {{- $requiredKeys := (list "database" "user") -}}
  {{- range $key := $requiredKeys -}}
    {{- if not (get $objectData $key) -}}
      {{- fail (printf "CNPG - Expected a non-empty [%s] key" $key) -}}
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

{{- end -}}
