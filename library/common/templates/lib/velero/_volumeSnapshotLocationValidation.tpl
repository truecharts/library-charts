{{/* Velero VolumeSnapshotLocation Validation */}}
{{/* Call this template:
{{ include "tc.v1.common.lib.velero.volumesnapshotlocation.validation" (dict "objectData" $objectData) -}}
objectData:
  rootCtx: The root context of the chart.
  objectData: The persistence object.
*/}}

{{- define "tc.v1.common.lib.velero.volumesnapshotlocation.validation" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}


{{- end -}}
