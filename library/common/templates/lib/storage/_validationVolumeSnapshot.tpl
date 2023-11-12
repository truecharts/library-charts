{{/* volumeSnapshot Validation */}}
{{/* Call this template:
{{ include "tc.v1.common.lib.volumesnapshot.validation" (dict "objectData" $objectData) -}}
objectData:
  rootCtx: The root context of the chart.
  objectData: The volumesnapshot object.
*/}}

{{- define "tc.v1.common.lib.volumesnapshot.validation" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

{{- end -}}
