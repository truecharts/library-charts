{{/* Returns Host Network */}}
{{/* Call this template:
{{ include "tc.v1.common.lib.pod.hostPID" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "tc.v1.common.lib.pod.hostPID" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $hostNet := false -}}

  {{/* Initialize from the "global" option */}}
  {{- if (kindIs "bool" $rootCtx.Values.podOptions.hostPID) -}}
    {{- $hostNet = $rootCtx.Values.podOptions.hostPID -}}
  {{- end -}}

  {{/* Override with pod's option */}}
  {{- if (kindIs "bool" $objectData.podSpec.hostPID) -}}
    {{- $hostNet = $objectData.podSpec.hostPID -}}
  {{- end -}}

  {{- $hostNet -}}
{{- end -}}
