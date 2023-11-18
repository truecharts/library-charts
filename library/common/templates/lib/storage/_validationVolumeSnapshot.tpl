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

  {{- if not $objectData.source -}}
    {{- fail "VolumeSnapshot - Expected non empty [source]" -}}
  {{- end -}}

  {{- $sourceTypes := (list "volumeSnapshotContentName" "persistentVolumeClaimName") -}}
  {{- $hasSource := false-}}
  {{- range $t := $sourceTypes -}}
    {{- if (get $objectData.source $t) -}}
      {{- $hasSource = true -}}
    {{- end -}}
  {{- end -}}

  {{- if not $hasSource -}}
    {{- fail (printf "VolumeSnapshot - Expected at least one of [%s] to be non empty" (join ", " $sourceTypes)) -}}
  {{- end -}}

{{- end -}}
