{{/*
Main entrypoint for the common library chart. It will render all underlying templates based on the provided values.
*/}}
{{- define "tc.common.v10.loader.all" -}}
  {{- /* Generate chart and dependency values */ -}}
  {{- include "tc.common.v10.loader.init" . }}

  {{- /* Generate remaining objects */ -}}
  {{- include "tc.common.v10.loader.apply" . }}

{{- end -}}
