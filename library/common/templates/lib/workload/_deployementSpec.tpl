{{/* Deployment Spec */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.workload.deploymentSpec" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
rootCtx: The root context of the chart.
objectData:
  replicas: The number of replicas.
  revisionHistoryLimit: The number of old ReplicaSets to retain to allow rollback.
  strategy: The deployment strategy to use to replace existing pods with new ones.
*/}}
{{- define "ix.v1.common.lib.workload.deploymentSpec" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}
replicas: {{ $objectData.replicas | default 1 }}
revisionHistoryLimit: {{ $objectData.revisionHistoryLimit | default 3 }}
strategy:
  type: {{ $objectData.strategy | default "Recreate" }}
  {{- if and
        (eq $objectData.strategy "RollingUpdate")
        $objectData.rollingUpdate
        (or $objectData.rollingUpdate.maxUnavailable $objectData.rollingUpdate.maxSurge) }}
  rollingUpdate:
    {{- with $objectData.rollingUpdate.maxUnavailable }}
    maxUnavailable: {{ .}}
    {{- end -}}
    {{- with $objectData.rollingUpdate.maxSurge }}
    maxSurge: {{ . }}
    {{- end -}}
  {{- end -}}
{{- end -}}
