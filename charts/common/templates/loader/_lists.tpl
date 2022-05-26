{{/* load all list to dict injectors */}}
{{- define "tc.common.v10.loader.lists" -}}


  {{ include "tc.common.v10.lib.values.controller.label.list" . }}
  {{ include "tc.common.v10.lib.values.controller.annotations.list" . }}

  {{ include "tc.common.v10.lib.values.pod.label.list" . }}
  {{ include "tc.common.v10.lib.values.pod.annotations.list" . }}

  {{ include "tc.common.v10.lib.values.persistence.list" . }}
  {{ include "tc.common.v10.lib.values.persistence.label.list" . }}
  {{ include "tc.common.v10.lib.values.persistence.annotations.list" . }}

  {{ include "tc.common.v10.lib.values.service.list" . }}

  {{ include "tc.common.v10.lib.values.ingress.list" . }}
  {{ include "tc.common.v10.lib.values.ingress.label.list" . }}
  {{ include "tc.common.v10.lib.values.ingress.annotations.list" . }}



{{- end -}}
