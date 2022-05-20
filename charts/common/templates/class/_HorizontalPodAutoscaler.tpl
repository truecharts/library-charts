{{/*
This template serves as a blueprint for horizontal pod autoscaler objects that are created
using the common library.
*/}}
{{- define "common.class.hpa" -}}
  {{- $targetName := include "common.names.fullname" . }}
  {{- $fullName := include "common.names.fullname" . -}}
  {{- $hpaName := $fullName -}}
  {{- $values := .Values.hpa -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.hpa -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $hpaName = printf "%v-%v" $hpaName $values.nameOverride -}}
  {{- end }}
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ $hpaName }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: {{ $values.targetKind | default ( include "common.names.controllerType" . ) }}
    name: {{ $values.target | default $targetName }}
  minReplicas: {{ $values.minReplicas | default 1 }}
  maxReplicas: {{ $values.maxReplicas | default 3 }}
  metrics:
    {{- if $values.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        targetAverageUtilization: {{ $values.targetCPUUtilizationPercentage }}
    {{- end }}
    {{- if $values.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        targetAverageUtilization: {{ $values.targetMemoryUtilizationPercentage }}
    {{- end }}
{{- end -}}
