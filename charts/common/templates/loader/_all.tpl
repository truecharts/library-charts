{{/*
Main entrypoint for the common library chart. It will render all underlying templates based on the provided values.
*/}}
{{- define "common.loader.all" -}}
  {{- /* Generate chart and dependency values */ -}}
  {{- include "common.loader.init" . }}

  {{- /* Generate remaining objects */ -}}
  {{- include "common.loader.apply" . }}

{{- end -}}
