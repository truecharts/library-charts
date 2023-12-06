{{/* Ingress Validation */}}
{{/* Call this template:
{{ include "tc.v1.common.lib.ingress.validation" (dict "rootCtx" $ "objectData" $objectData) -}}
objectData:
  rootCtx: The root context of the chart.
  objectData: The Ingress object.
*/}}

{{- define "tc.v1.common.lib.ingress.validation" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- if $objectData.targetSelector -}}
    {{- if not (kindIs "map" $objectData.targetSelector) -}}
      {{- fail (printf "Ingress - Expected [targetSelector] to be a [map], but got [%s]" (kindOf $objectData.targetSelector)) -}}
    {{- end -}}

    {{- $selectors := $objectData.targetSelector | keys | len -}}
    {{- if (gt $selectors 1) -}}
      {{ fail (printf "Ingress - Expected [targetSelector] to have exactly one key, but got [%d]" $selectors) -}}
    {{- end -}}

    {{- range $k, $v := $objectData.targetSelector -}}
      {{- if not $v -}}
        {{- fail (printf "Ingress - Expected [targetSelector.%s] to have a value" $k) -}}
      {{- end -}}

      {{- if not (kindIs "string" $v) -}}
        {{- fail (printf "Ingress - Expected [targetSelector.%s] to be a [string], but got [%s]" $k (kindOf $v)) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

{{- end -}}

{{/* Ingress Primary Validation */}}
{{/* Call this template:
{{ include "tc.v1.common.lib.ingress.primaryValidation" $ -}}
*/}}

{{- define "tc.v1.common.lib.ingress.primaryValidation" -}}

  {{/* Initialize values */}}
  {{- $hasPrimary := false -}}
  {{- $hasEnabled := false -}}

  {{- range $name, $ingress := $.Values.ingress -}}

    {{- $enabled := (include "tc.v1.common.lib.util.enabled" (dict
              "rootCtx" $ "objectData" $ingress
              "name" $name "caller" "Ingress"
              "key" "ingress")) -}}

    {{/* If ingress is enabled */}}
    {{- if eq $enabled "true" -}}
      {{- $hasEnabled = true -}}

      {{/* And ingress is primary */}}
      {{- if and (hasKey $ingress "primary") ($ingress.primary) -}}
        {{/* Fail if there is already a primary ingress */}}
        {{- if $hasPrimary -}}
          {{- fail "Ingress - Only one ingress can be primary" -}}
        {{- end -}}

        {{- $hasPrimary = true -}}

      {{- end -}}

    {{- end -}}
  {{- end -}}

  {{/* Require at least one primary ingress, if any enabled */}}
  {{- if and $hasEnabled (not $hasPrimary) -}}
    {{- fail "Ingress - At least one enabled ingress must be primary" -}}
  {{- end -}}

{{- end -}}
