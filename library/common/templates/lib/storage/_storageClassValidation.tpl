{{- define "tc.v1.common.lib.storageclass.validation" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $validPolicies := (list "Retain" "Delete") -}}
  {{- if $objectData.reclaimPolicy -}}
    {{- if not (mustHas $objectData.reclaimPolicy $validPolicies) -}}
      {{- fail (printf "Storage Class - Expected [reclaimPolicy] to be one of [%s], but got [%s]" (join ", " $validPolicies) $objectData.reclaimPolicy) -}}
    {{- end -}}
  {{- end -}}

  {{- $validBindModes := (list "WaitForFirstConsumer" "Immediate") -}}
  {{- if $objectData.volumeBindingMode -}}
    {{- if not (mustHas $objectData.volumeBindingMode $validBindModes) -}}
      {{- fail (printf "Storage Class - Expected [volumeBindingMode] to be one of [%s], but got [%s]" (join ", " $validBindModes) $objectData.volumeBindingMode) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
