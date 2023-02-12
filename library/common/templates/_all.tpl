{{/* Main entrypoint for the library */}}
{{- define "tc.common.loader.all" -}}

  {{- include "tc.v1.common.loader.init" . -}}

  {{- include "tc.v1.common.loader.apply" . -}}

{{- end -}}
