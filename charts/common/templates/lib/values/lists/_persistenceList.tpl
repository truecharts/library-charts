{{/* merge persistenceList with Persitence */}}
{{- define "common.lib.values.persistence.list" -}}
  {{- $perDict2 := dict }}
  {{- range $index, $item := .Values.persistenceList -}}
    {{- $name := ( printf "list-%s" ( $index | toString ) ) }}
    {{- if $item.name }}
      {{- $name = $item.name }}
    {{- end }}
    {{- $_ := set $perDict2 $name $item }}
  {{- end }}
{{- end -}}
