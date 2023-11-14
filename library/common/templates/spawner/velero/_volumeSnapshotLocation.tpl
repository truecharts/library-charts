{{/* volumesnapshotlocation Spawwner */}}
{{/* Call this template:
{{ include "tc.v1.common.spawner.velero.volumesnapshotlocation" $ -}}
*/}}

{{- define "tc.v1.common.spawner.velero.volumesnapshotlocation" -}}
  {{- $fullname := include "tc.v1.common.lib.chart.names.fullname" $ -}}

  {{- range $volumesnapshotlocation := .Values.volumesnapshotlocation -}}

    {{- $enabled := false -}}
    {{- if hasKey $volumesnapshotlocation "enabled" -}}
      {{- if not (kindIs "invalid" $volumesnapshotlocation.enabled) -}}
        {{- $enabled = $volumesnapshotlocation.enabled -}}
      {{- else -}}
        {{- fail (printf "volumesnapshotlocation - Expected the defined key [enabled] in [volumesnapshotlocation.%s] to not be empty" $volumesnapshotlocation.name) -}}
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

      {{- $objectName := (printf "%s-%s" $fullname $volumesnapshotlocation.name) -}}
      {{- if hasKey $objectData "expandObjectName" -}}
        {{- if not $objectData.expandObjectName -}}
          {{- $objectName = $volumesnapshotlocation.name -}}
        {{- end -}}
      {{- end -}}

      {{/* Set database to velero location or itself, just in case its used from within velero */}}
      {{- $operator := index $.Values.operator "velero" -}}
      {{- $namespace := $operator.namespace | default ( include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $ "objectData" $objectData "caller" "backupstoragelocation") ) -}}

      {{/* Perform validations */}} {{/* volumesnapshotlocations have a max name length of 253 */}}
      {{- include "tc.v1.common.lib.chart.names.validation" (dict "name" $objectName "length" 253) -}}
      {{- include "tc.v1.common.lib.velero.volumesnapshotlocation.validation" (dict "objectData" $objectData) -}}
      {{- include "tc.v1.common.lib.metadata.validation" (dict "objectData" $objectData "caller" "volumesnapshotlocation") -}}

      {{/* Set the name of the volumesnapshotlocation */}}
      {{- $_ := set $objectData "name" $objectName -}}
      {{- $_ := set $objectData "shortName" $volumesnapshotlocation.name -}}

      {{/* Set namespace to velero location or itself, just in case its used from within velero */}}
      {{- $operator := index $.Values.operator "velero" -}}
      {{- $namespace := $operator.namespace | default ( include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $ "objectData" $objectData "caller" "backupstoragelocation") ) -}}
      {{- $_ := set $objectData.namespace $namespace -}}

      {{/* Create secret with creds */}}
      {{- $creds := "" -}}
      {{- if and (eq $objectData.provider "aws") $objectData.credential.aws -}}
        {{- $creds := printf "%v%v%v%v" "[default]\naws_access_key_id = " $objectData.credential.aws.id "\n aws_secret_access_key = " $objectData.credential.aws.accesskey -}}
      {{- end -}}
      {{- $secretData := (dict
                            "name" $objectData.name
                            "labels" ($objectData.labels | default dict)
                            "annotations" ($objectData.annotations | default dict)
                            "data" (dict "cloud" $creds )
                          ) -}}
      {{- include "tc.v1.common.class.secret" (dict "rootCtx" $ "objectData" $secretData) -}}

      {{- $_ := set $objectData.credential "name" ($objectData.credential.name | default $objectData.name)  -}}
      {{- $_ := set $objectData.credential "key" ($objectData.credential.key | default "cloud") -}}

      {{/* Call class to create the object */}}
      {{- include "tc.v1.common.class.velero.volumesnapshotlocation" (dict "rootCtx" $ "objectData" $objectData) -}}

    {{- end -}}

  {{- end -}}

{{- end -}}
