{{/* Initialiaze values of the chart */}}

{{- define "tc.v1.common.loader.init" -}}

  {{/* Merge chart values and the common chart defaults */}}
  {{- include "tc.v1.common.values.init" . -}}

{{- end -}}
