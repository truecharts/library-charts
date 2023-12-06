{{/* Ingress Spawwner */}}
{{/* Call this template:
{{ include "tc.v1.common.spawner.ingress" $ -}}
*/}}

{{- define "tc.v1.common.spawner.ingress" -}}
  {{- $fullname := include "tc.v1.common.lib.chart.names.fullname" $ -}}

  {{/* Generate named ingresses as required */}}
  {{- range $name, $ingress := .Values.ingress -}}

    {{- $enabled := (include "tc.v1.common.lib.util.enabled" (dict
              "rootCtx" $ "objectData" $ingress
              "name" $name "caller" "Ingress"
              "key" "ingress")) -}}

    {{- if and (eq $enabled "false") ($ingress.required) -}}
      {{- fail (printf "Ingress - Expected ingress [%s] to be enabled. This chart is designed to work only with ingress enabled." $name) -}}
    {{- end -}}

    {{- if eq $enabled "true" -}}

      {{/* Create a copy of the ingress */}}
      {{- $objectData := (mustDeepCopy $ingress) -}}

      {{/* Init object name */}}
      {{- $objectName := $name -}}

      {{- $expandName := (include "tc.v1.common.lib.util.expandName" (dict
                "rootCtx" $ "objectData" $objectData
                "name" $name "caller" "Ingress"
                "key" "ingress")) -}}

      {{- if eq $expandName "true" -}}
        {{/* Expand the name of the service if expandName resolves to true */}}
        {{- $objectName = $fullname -}}
      {{- end -}}

      {{- if and (eq $expandName "true") (not $objectData.primary) -}}
        {{/* If the ingress is not primary append its name to fullname */}}
        {{- $objectName = (printf "%s-%s" $fullname $name) -}}
      {{- end -}}

      {{/* Perform validations */}}
      {{- include "tc.v1.common.lib.chart.names.validation" (dict "name" $objectName "length" 253) -}}
      {{- include "tc.v1.common.lib.metadata.validation" (dict "objectData" $objectData "caller" "Ingress") -}}
      {{- /* include "tc.v1.common.lib.service.validation" (dict "rootCtx" $ "objectData" $objectData) */ -}}

      {{/* Set the name of the ingress */}}
      {{- $_ := set $objectData "name" $objectName -}}
      {{- $_ := set $objectData "shortName" $name -}}

      {{/* Call class to create the object */}}
      {{- include "tc.v1.common.class.ingress" (dict "rootCtx" $ "objectData" $objectData) -}}

      {{/* TODO: range over TLS and do stuff */}}
    {{- end -}}
  {{- end -}}
{{- end -}}
