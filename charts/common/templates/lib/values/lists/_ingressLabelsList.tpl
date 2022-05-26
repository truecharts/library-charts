{{/* merge ingressLabelsList with ingressLabels */}}
{{- define "tc.common.v10.lib.values.ingress.label.list" -}}
  {{- range $index, $item := .Values.ingress }}
  {{- if $item.enabled }}
  {{- $ingressLabelsDict := dict }}
  {{- range $item.labelsList }}
  {{- $_ := set $ingressLabelsDict .name .value }}
  {{- end }}
  {{- $tmp := $item.labels }}
  {{- $ingresslab := merge $tmp $ingressLabelsDict }}
  {{- $_ := set $item "labels" (deepCopy $ingresslab) -}}
  {{- end }}
  {{- end }}
{{- end -}}
