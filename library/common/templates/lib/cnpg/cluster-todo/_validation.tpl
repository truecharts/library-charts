{{- define "tc.v1.common.lib.cnpg.cluster.validation" -}}
  {{- $objectData := .objectData -}}

  {{- $requiredKeys := (list "database" "user") -}}
  {{- range $key := $requiredKeys -}}
    {{- if not (get $objectData $key) -}}
      {{- fail (printf "CNPG - Expected a non-empty [%s] key" $key) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
