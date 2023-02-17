{{/* Loads all spawners */}}
{{- define "tc.common.loader.apply" -}}

  {{/* Adds TC apply prior to iX Init */}}
  {{- include "tc.v1.common.loader.apply.pre" . | nindent 0 -}}

  {{/* Adds iX Apply */}}
  {{- include "tc.v1.common.loader.apply" . | nindent 0 -}}

  {{/* Adds TC apply after to iX Init */}}
  {{- include "tc.v1.common.loader.apply.post" . | nindent 0 -}}

{{- end -}}
