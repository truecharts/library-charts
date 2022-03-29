{{/* merge deviceList with Persitence */}}
{{- define "common.lib.values.device.list" -}}
  {{- range $index, $item := .Values.deviceList -}}
    {{- $name := ( printf "device-%s" ( $index | toString ) ) }}
    {{- if $item.name }}
      {{- $name = $item.name }}
    {{- end }}
    {{- $_ := set $perDict $name $item }}
  {{- end }}
  {{- $per := merge .Values.persistence $perDict }}
  {{- $_ := set .Values "persistence" (deepCopy $per) -}}
{{- end -}}
