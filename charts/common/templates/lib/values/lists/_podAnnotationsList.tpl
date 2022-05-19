{{/* merge podAnnotationsList with podAnnotations */}}
{{- define "common.lib.values.pod.annotations.list" -}}
  {{- range $index, $item := .Values.pod }}
  {{- if $item.enabled }}
  {{- $podAnnotationsDict := dict }}
  {{- range $item.podAnnotationsList }}
  {{- $_ := set $podAnnotationsDict .name .value }}
  {{- end }}
  {{- $tmp := $item.podAnnotations }}
  {{- $podlab := merge $tmp $podAnnotationsDict }}
  {{- $_ := set $item "podAnnotations" (deepCopy $podlab) -}}
  {{- end }}
  {{- end }}
{{- end -}}
