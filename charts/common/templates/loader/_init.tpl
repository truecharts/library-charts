{{- define "common.loader.init" -}}
  {{- /* Merge the local chart values and the common chart defaults */ -}}
  {{- include "common.values.init" . }}

  {{- include "common.loader.lists" . }}

  {{- include "common.lib.values.persistence.simple" . }}

  {{- include "common.lib.values.volumeClaimTemplates.simple" . }}

  {{- include "common.lib.values.service.simple" . }}

  {{- include "common.lib.values.capabilities" . }}

  {{- include "common.lib.values.supplementalGroups" . }}

  {{- include "common.lib.values.securityContext.privileged" . }}

  {{- /* Autogenerate postgresql passwords if needed */ -}}
  {{- include "common.dependencies.postgresql.injector" . }}

  {{- /* Autogenerate redis passwords if needed */ -}}
  {{- include "common.dependencies.redis.injector" . }}

  {{- /* Autogenerate mariadb passwords if needed */ -}}
  {{- include "common.dependencies.mariadb.injector" . }}

  {{- /* Autogenerate mongodb passwords if needed */ -}}
  {{- include "common.dependencies.mongodb.injector" . }}
{{- end -}}
