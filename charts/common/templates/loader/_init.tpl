{{- define "tc.common.v10.loader.init" -}}
  {{- /* Merge the local chart values and the common chart defaults */ -}}
  {{- include "tc.common.v10.values.init" . }}

  {{- include "tc.common.v10.loader.lists" . }}

  {{- include "tc.common.v10.lib.values.persistence.simple" . }}

  {{- include "tc.common.v10.lib.values.volumeClaimTemplates.simple" . }}

  {{- include "tc.common.v10.lib.values.service.simple" . }}

  {{- include "tc.common.v10.lib.values.capabilities" . }}

  {{- include "tc.common.v10.lib.values.supplementalGroups" . }}

  {{- include "tc.common.v10.lib.values.securityContext.privileged" . }}

  {{- /* Autogenerate postgresql passwords if needed */ -}}
  {{- include "tc.common.v10.dependencies.postgresql.injector" . }}

  {{- /* Autogenerate redis passwords if needed */ -}}
  {{- include "tc.common.v10.dependencies.redis.injector" . }}

  {{- /* Autogenerate mariadb passwords if needed */ -}}
  {{- include "tc.common.v10.dependencies.mariadb.injector" . }}

  {{- /* Autogenerate mongodb passwords if needed */ -}}
  {{- include "tc.common.v10.dependencies.mongodb.injector" . }}
{{- end -}}
