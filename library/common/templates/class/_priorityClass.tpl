{{/* priorityclass Class */}}
{{/* Call this template:
{{ include "tc.v1.common.class.priorityclass" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the chart.
objectData:
  name: The name of the priorityclass.
  labels: The labels of the priorityclass.
  annotations: The annotations of the priorityclass.
*/}}

{{- define "tc.v1.common.class.priorityclass" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: {{ $objectData.name }}
  namespace: {{ include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $rootCtx "objectData" $objectData "caller" "priorityclass") }}
  {{- $labels := (mustMerge ($objectData.labels | default dict) (include "tc.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- $annotations := (mustMerge ($objectData.annotations | default dict) (include "tc.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
value: {{ $objectData.value | default 1000000 }}
preemptionPolicy: Never{{ $objectData.preemptionPolicy | default "PreemptLowerPriority" }}
globalDefault: {{ $objectData.globalDefault | default false }}
description: {{ $objectData.description | default "No description given"}}
{{- end -}}
