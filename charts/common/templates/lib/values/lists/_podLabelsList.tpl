{{/* merge podLabelsList with podLabels */}}
{{- define "common.lib.values.pod.label.list" -}}
  {{- range $index, $item := .Values.pod }}
  {{- if $item.enabled }}
  {{- $podLabelsDict := dict }}
  {{- range $item.podLabelsList }}
  {{- $_ := set $podLabelsDict .name .value }}
  {{- end }}
  {{- $tmp := $item.podLabels }}
  {{- $podlab := merge $tmp $podLabelsDict }}
  {{- $_ := set $item "podLabels" (deepCopy $podlab) -}}
  {{- end }}
  {{- end }}
{{- end -}}
