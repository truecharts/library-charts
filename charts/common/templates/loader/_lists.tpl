{{/* load all list to dict injectors */}}
{{- define "common.loader.lists" -}}


  {{ include "common.lib.values.controller.label.list" . }}
  {{ include "common.lib.values.controller.annotations.list" . }}

  {{ include "common.lib.values.pod.label.list" . }}
  {{ include "common.lib.values.pod.annotations.list" . }}

  {{ include "common.lib.values.persistence.list" . }}
  {{ include "common.lib.values.persistence.label.list" . }}
  {{ include "common.lib.values.persistence.annotations.list" . }}
  {{ include "common.lib.values.device.list" . }}

  {{ include "common.lib.values.service.list" . }}

  {{ include "common.lib.values.ingress.list" . }}
  {{ include "common.lib.values.ingress.label.list" . }}
  {{ include "common.lib.values.ingress.annotations.list" . }}



{{- end -}}
