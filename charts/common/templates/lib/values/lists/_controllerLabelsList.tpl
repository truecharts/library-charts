{{/* merge podLabelsList with controllerLabels */}}
{{- define "common.lib.values.controller.label.list" -}}
  {{- range $index, $item := .Values.pod }}
  {{- if $item.enabled }}
  {{- $controllerLabelsDict := dict }}
  {{- range $item.controllerLabelsList }}
  {{- $_ := set $controllerLabelsDict .name .value }}
  {{- end }}
  {{- $tmp := $item.controllerLabels }}
  {{- $controllerlab := merge $tmp $controllerLabelsDict }}
  {{- $_ := set $item "controllerLabels" (deepCopy $controllerlab) -}}
  {{- end }}
  {{- end }}
{{- end -}}
