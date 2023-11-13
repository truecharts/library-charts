{{- define "tc.v1.common.lib.volumesnapshotclass.validation" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $validPolicies := (list "Retain" "Delete") -}}
  {{- if $objectData.reclaimPolicy -}}
    {{- if not (mustHas $objectData.reclaimPolicy $validPolicies) -}}
      {{- fail (printf "Storage Class - Expected [reclaimPolicy] to be one of [%s], but got [%s]" (join ", " $validPolicies) $objectData.reclaimPolicy) -}}
    {{- end -}}
  {{- end -}}

{{- end -}}
