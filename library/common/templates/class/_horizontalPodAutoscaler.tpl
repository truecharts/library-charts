{{/*
This template serves as a blueprint for horizontal pod autoscaler objects that are created
using the common library.
*/}}
{{- define "tc.v1.common.class.hpa" -}}
  {{- $targetName := include "ix.v1.common.names.fullname" . }}
  {{- $fullName := include "ix.v1.common.names.fullname" . -}}
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
  {{- with (merge ($values.labels | default dict) (include "ix.v1.common.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  annotations:
  {{- with (merge ($values.annotations | default dict) (include "ix.v1.common.annotations" $ | fromYaml)) }}
    {{- tpl ( toYaml . ) $ | nindent 4 }}
  {{- end }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: {{ $values.targetKind | default ( include "ix.v1.common.names.controllerType" . ) }}
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
