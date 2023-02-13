{{/* Main entrypoint for the library */}}
{{- define "tc.common.loader.all" -}}

  {{- include "tc.common.loader.init" . -}}

  {{- include "tc.common.loader.apply" . -}}

{{- end -}}
