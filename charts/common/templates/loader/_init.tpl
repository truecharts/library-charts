{{- define "tc.common.loader.init" -}}
  {{- /* Merge the local chart values and the common chart defaults */ -}}
  {{- include "tc.common.values.init" . }}

  {{- include "tc.common.loader.lists" . }}

  {{- include "tc.common.lib.values.persistence.simple" . }}

  {{- include "tc.common.lib.values.volumeClaimTemplates.simple" . }}

  {{- include "tc.common.lib.values.service.simple" . }}

  {{- include "tc.common.lib.values.capabilities" . }}

  {{- include "tc.common.lib.values.supplementalGroups" . }}

  {{- include "tc.common.lib.values.securityContext.privileged" . }}

  {{- /* Autogenerate postgresql passwords if needed */ -}}
  {{- include "tc.common.dependencies.postgresql.injector" . }}

  {{- /* Autogenerate redis passwords if needed */ -}}
  {{- include "tc.common.dependencies.redis.injector" . }}

  {{- /* Autogenerate mariadb passwords if needed */ -}}
  {{- include "tc.common.dependencies.mariadb.injector" . }}

  {{- /* Autogenerate mongodb passwords if needed */ -}}
  {{- include "tc.common.dependencies.mongodb.injector" . }}

  {{- /* Autogenerate clickhouse passwords if needed */ -}}
  {{- include "tc.common.dependencies.clickhouse.injector" . }}
{{- end -}}
