{{/* schedule Spawwner */}}
{{/* Call this template:
{{ include "tc.v1.common.spawner.velero.schedule" $ -}}
*/}}

{{- define "tc.v1.common.spawner.velero.schedule" -}}
  {{- $fullname := include "tc.v1.common.lib.chart.names.fullname" $ -}}

  {{- range $schedule := .Values.schedule -}}

    {{- $enabled := false -}}
    {{- if hasKey $schedule "enabled" -}}
      {{- if not (kindIs "invalid" $schedule.enabled) -}}
        {{- $enabled = $schedule.enabled -}}
      {{- else -}}
        {{- fail (printf "schedule - Expected the defined key [enabled] in [schedule.%s] to not be empty" $schedule.name) -}}
      {{- end -}}
    {{- end -}}


    {{- if kindIs "string" $enabled -}}
      {{- $enabled = tpl $enabled $ -}}

      {{/* After tpl it becomes a string, not a bool */}}
      {{-  if eq $enabled "true" -}}
        {{- $enabled = true -}}
      {{- else if eq $enabled "false" -}}
        {{- $enabled = false -}}
      {{- end -}}
    {{- end -}}

    {{- if $enabled -}}

      {{/* Create a copy of the schedule */}}
      {{- $objectData := (mustDeepCopy $schedule) -}}

      {{- $objectName := (printf "%s-%s" $fullname $schedule.name) -}}
      {{- if hasKey $objectData "expandObjectName" -}}
        {{- if not $objectData.expandObjectName -}}
          {{- $objectName = $schedule.name -}}
        {{- end -}}
      {{- end -}}

      {{/* Perform validations */}} {{/* schedules have a max name length of 253 */}}
      {{- include "tc.v1.common.lib.chart.names.validation" (dict "name" $objectName "length" 253) -}}
      {{- include "tc.v1.common.lib.velero.schedule.validation" (dict "objectData" $objectData) -}}
      {{- include "tc.v1.common.lib.metadata.validation" (dict "objectData" $objectData "caller" "schedule") -}}

      {{/* Set the name of the schedule */}}
      {{- $_ := set $objectData "name" $objectName -}}
      {{- $_ := set $objectData "shortName" $schedule.name -}}

      {{/* Set namespace to velero location or itself, just in case its used from within velero */}}
      {{- $operator := index $.Values.operator "velero" -}}
      {{- $namespace := $operator.namespace | default ( include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $ "objectData" $objectData "caller" "backupstoragelocation") ) -}}
      {{- $_ := set $objectData.namespace $namespace -}}

      {{/* Call class to create the object */}}
      {{- include "tc.v1.common.class.velero.schedule" (dict "rootCtx" $ "objectData" $objectData) -}}

    {{- end -}}

  {{- end -}}

{{- end -}}
