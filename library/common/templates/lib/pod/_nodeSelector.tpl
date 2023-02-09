{{/* Returns Node Selector */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.nodeSelector" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the template. It is used to access the global context.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "ix.v1.common.lib.pod.nodeSelector" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $selectors := dict -}}

  {{/* Initialize from the "global" option */}}
  {{- with $rootCtx.Values.podOptions.nodeSelector -}}
    {{- $selectors = . -}}
  {{- end -}}

  {{/* Override with pod's option */}}
  {{- with $objectData.podSpec.nodeSelector -}}
    {{- $selectors = . -}}
  {{- end -}}

  {{- range $k, $v := $selectors -}}
    {{- if not $v -}}
      {{- fail (printf "Expected non-empty value on <nodeSelector> [%s] key." $k) -}}
    {{- end }}
{{ $k }}: {{ tpl $v $rootCtx }}
  {{- end -}}
{{- end -}}
