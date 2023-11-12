{{/* volumesnapshot Spawwner */}}
{{/* Call this template:
{{ include "tc.v1.common.spawner.volumesnapshot" $ -}}
*/}}

{{- define "tc.v1.common.spawner.volumesnapshot" -}}
  {{- $fullname := include "tc.v1.common.lib.chart.names.fullname" $ -}}

  {{- range $name, $persistence := .Values.persistence -}}
    {{- $enabled := false -}}
    {{- if hasKey $persistence "enabled" -}}
      {{- if not (kindIs "invalid" $persistence.enabled) -}}
        {{- $enabled = $persistence.enabled -}}
      {{- else -}}
        {{- fail (printf "persistence - Expected the defined key [enabled] in [persistence.%s] to not be empty" $name) -}}
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

    {{- $types := (list "pvc") -}}
    {{- if and $enabled $persistence.type (mustHas $persistence.type $types) -}}
      {{/* Get the name of the PVC */}}
      {{- $PVCName := (include "tc.v1.common.lib.storage.pvc.name" (dict "rootCtx" $ "objectName" $name "objectData" $persistence)) -}}
      {{- range $volumesnapshot := $persistence.volumesnapshots -}}

          {{/* Create a copy of the volumesnapshot */}}
          {{- $objectData := (mustDeepCopy $volumesnapshot) -}}
          {{- $snapshotName := printf "%v-%v" $PVCName $volumesnapshot.name -}}

          {{/* Perform validations */}} {{/* volumesnapshots have a max name length of 253 */}}
          {{- include "tc.v1.common.lib.chart.names.validation" (dict "name" $snapshotName "length" 253) -}}
          {{- include "tc.v1.common.lib.volumesnapshot.validation" (dict "objectData" $objectData) -}}
          {{- include "tc.v1.common.lib.metadata.validation" (dict "objectData" $objectData "caller" "volumesnapshot") -}}

          {{/* Set the name of the volumesnapshot */}}
          {{- $_ := set $objectData "name" $snapshotName -}}
          {{- $_ := set $objectData "shortName" $volumesnapshot.name -}}
          {{- $_ := set $objectData "persistentVolumeClaimName" $PVCName -}}

          {{/* Call class to create the object */}}
          {{- include "tc.v1.common.class.volumesnapshot" (dict "rootCtx" $ "objectData" $objectData) -}}

      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- range $volumesnapshot := .Values.volumeSnapshots -}}
      {{/* Create a copy of the volumesnapshot */}}
      {{- $objectData := (mustDeepCopy $volumesnapshot) -}}

      {{- $objectName := (printf "%s-%s" $fullname $volumesnapshot.name) -}}
      {{- if hasKey $objectData "expandObjectName" -}}
        {{- if not $objectData.expandObjectName -}}
          {{- $objectName = $volumesnapshot.name -}}
        {{- end -}}
      {{- end -}}

      {{/* Perform validations */}} {{/* volumesnapshots have a max name length of 253 */}}
      {{- include "tc.v1.common.lib.chart.names.validation" (dict "name" $objectName "length" 253) -}}
      {{- include "tc.v1.common.lib.volumesnapshot.validation" (dict "objectData" $objectData) -}}
      {{- include "tc.v1.common.lib.metadata.validation" (dict "objectData" $objectData "caller" "volumesnapshot") -}}

      {{/* Set the name of the volumesnapshot */}}
      {{- $_ := set $objectData "name" $objectName -}}
      {{- $_ := set $objectData "shortName" $volumesnapshot.name -}}

      {{/* Call class to create the object */}}
      {{- include "tc.v1.common.class.volumesnapshot" (dict "rootCtx" $ "objectData" $objectData) -}}

  {{- end -}}

{{- end -}}
