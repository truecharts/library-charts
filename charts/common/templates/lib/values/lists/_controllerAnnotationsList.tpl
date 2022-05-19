{{/* merge podAnnotationsList with controllerAnnotations */}}
{{- define "common.lib.values.controller.annotations.list" -}}
  {{- range $index, $item := .Values.pod }}
  {{- if $item.enabled }}
  {{- $controllerAnnotationsDict := dict }}
  {{- range $item.controllerAnnotationsList }}
  {{- $_ := set $controllerAnnotationsDict .name .value }}
  {{- end }}
  {{- $tmp := $item.controllerAnnotations }}
  {{- $controllerlab := merge $tmp $controllerAnnotationsDict }}
  {{- $_ := set $item "controllerAnnotations" (deepCopy $controllerlab) -}}
  {{- end }}
  {{- end }}
{{- end -}}
