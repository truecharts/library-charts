{{/* volumesnapshotlocation Spawwner */}}
{{/* Call this template:
{{ include "tc.v1.common.spawner.velero.volumesnapshotlocation" $ -}}
*/}}

{{- define "tc.v1.common.spawner.velero.volumesnapshotlocation" -}}
  {{- $fullname := include "tc.v1.common.lib.chart.names.fullname" $ -}}

  {{- range $name, $volumesnapshotlocation := .Values.volumesnapshotlocation -}}

    {{- $enabled := false -}}
    {{- if hasKey $volumesnapshotlocation "enabled" -}}
      {{- if not (kindIs "invalid" $volumesnapshotlocation.enabled) -}}
        {{- $enabled = $volumesnapshotlocation.enabled -}}
      {{- else -}}
        {{- fail (printf "volumesnapshotlocation - Expected the defined key [enabled] in [volumesnapshotlocation.%s] to not be empty" $name) -}}
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

      {{/* Create a copy of the volumesnapshotlocation */}}
      {{- $objectData := (mustDeepCopy $volumesnapshotlocation) -}}

      {{- $objectName := (printf "%s-%s" $fullname $name) -}}
      {{- if hasKey $objectData "expandObjectName" -}}
        {{- if not $objectData.expandObjectName -}}
          {{- $objectName = $name -}}
        {{- end -}}
      {{- end -}}

      {{/* Perform validations */}} {{/* volumesnapshotlocations have a max name length of 253 */}}
      {{- include "tc.v1.common.lib.chart.names.validation" (dict "name" $objectName "length" 253) -}}
      {{- include "tc.v1.common.lib.velero.volumesnapshotlocation.validation" (dict "objectData" $objectData) -}}
      {{- include "tc.v1.common.lib.metadata.validation" (dict "objectData" $objectData "caller" "volumesnapshotlocation") -}}

      {{/* Set the name of the volumesnapshotlocation */}}
      {{- $_ := set $objectData "name" $objectName -}}
      {{- $_ := set $objectData "shortName" $name -}}

      {{/* Call class to create the object */}}
      {{- include "tc.v1.common.class.velero.volumesnapshotlocation" (dict "rootCtx" $ "objectData" $objectData) -}}

    {{- end -}}

  {{- end -}}

{{- end -}}
