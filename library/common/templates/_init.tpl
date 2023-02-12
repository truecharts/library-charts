{{/* Appends iX Init Loader with TC init loaders */}}
{{- define "tc.common.loader.init" -}}

  {{/* Adds TC init prior to iX Init */}}
  {{- include "tc.v1.common.loader.init.pre" . -}}

  {{/* Adds iX init */}}
  {{- include "ix.v1.common.loader.init" . -}}

  {{/* Adds TC init after to iX Init */}}
  {{- include "tc.v1.common.loader.init.post" . -}}

{{- end -}}
