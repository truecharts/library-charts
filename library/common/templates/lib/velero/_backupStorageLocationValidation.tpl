{{/* Velero BackupStorageLocation Validation */}}
{{/* Call this template:
{{ include "tc.v1.common.lib.velero.backupstoragelocation.validation" (dict "objectData" $objectData) -}}
objectData:
  rootCtx: The root context of the chart.
  objectData: The backupstoragelocation object.
*/}}

{{- define "tc.v1.common.lib.velero.backupstoragelocation.validation" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}



{{- end -}}
