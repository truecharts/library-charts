{{/* merge persistenceList with Persitence */}}
{{- define "common.lib.values.persistence.list" -}}
  {{- $perDict := dict }}
  {{- range $index, $item := .Values.persistenceList -}}
    {{- $name := ( printf "list-%s" ( $index | toString ) ) }}
    {{- if $item.name }}
      {{- $name = $item.name }}
    {{- end }}
    {{- $_ := set $perDict $name $item }}
  {{- end }}
{{- end -}}
