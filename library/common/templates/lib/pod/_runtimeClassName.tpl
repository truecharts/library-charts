{{/* Returns Runtime Class Name */}}
{{/* Call this template:
{{ include "tc.v1.common.lib.pod.runtimeClassName" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "tc.v1.common.lib.pod.runtimeClassName" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $runtime := "" -}}

  {{/* Initialize from the "defaults" */}}
  {{- with $rootCtx.Values.podOptions.runtimeClassName -}}
    {{- $runtime = tpl . $rootCtx -}}
  {{- end -}}

  {{/* Override from the pod values, if defined */}}
  {{- with $objectData.podSpec.runtimeClassName -}}
    {{- $runtime = tpl . $rootCtx -}}
  {{- end -}}

  {{- if hasKey $rootCtx.Values.global "ixChartContext" -}}
    {{- if $rootCtx.Values.global.ixChartContext.addNvidiaRuntimeClass -}}
    {{- $gpuAssigned := false -}}

     {{- if gt $rootCtx.Values.resources.limits.nvidia.com/gpu "0" -}}
       {{- $gpuAssigned = true -}}
     {{- end -}}

      {{- range $rootCtx.Values.workload -}}
        {{- range $k, $v := .containers -}}
          {{- if gt .resources.limits.nvidia.com/gpu "0" -}}
            {{- $gpuAssigned = true -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}

      {{- range $rootCtx.Values.scaleGPU -}}
        {{- if .gpu -}} {{/* Make sure it has a value... */}}
          
          {{- range $k, $v := .gpu -}}
            {{- if $v -}} {{/* Make sure value is not "0" or "" */}}
              {{- $gpuAssigned = true -}}
            {{- end -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
          {{- if $gpuAssigned -}}
            {{- if (kindIs "map" .targetSelector) -}}
              {{- range $podName, $containers := .targetSelector -}}
                {{- if eq $objectData.shortName $podName -}} {{/* If the pod is selected */}}
                  {{- $runtime = $rootCtx.Values.global.ixChartContext.nvidiaRuntimeClassName -}}
                {{- end -}}
              {{- end -}}

            {{- else if $objectData.primary -}}

              {{/* If the pod is primary and no targetSelector is given, assign to primary */}}
              {{- $runtime = $rootCtx.Values.global.ixChartContext.nvidiaRuntimeClassName -}}

            {{- end -}}
          {{- end -}}

    {{- end -}}
  {{- end -}}

  {{- $runtime -}}
{{- end -}}
