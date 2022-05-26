{{/*
This template serves as the blueprint for the Deployment objects that are created
within the common library.
*/}}
{{- define "tc.common.v10.deployment" }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "tc.common.v10.names.fullname" . }}
  {{- with (merge (.Values.controller.labels | default dict) (include "tc.common.v10.labels" $ | fromYaml)) }}
  labels: {{- tpl ( toYaml . ) $ | nindent 4 }}
  {{- end }}
  {{- with (merge (.Values.controller.annotations | default dict) (include "tc.common.v10.annotations" $ | fromYaml) (include "tc.common.v10.annotations.workload" $ | fromYaml)) }}
  annotations: {{- tpl ( toYaml . ) $ | nindent 4 }}
  {{- end }}
spec:
  revisionHistoryLimit: {{ .Values.controller.revisionHistoryLimit }}
  replicas: {{ .Values.controller.replicas }}
  {{- $strategy := default "Recreate" .Values.controller.strategy }}
  {{- if and (ne $strategy "Recreate") (ne $strategy "RollingUpdate") }}
    {{- fail (printf "Not a valid strategy type for Deployment (%s)" $strategy) }}
  {{- end }}
  strategy:
    type: {{ $strategy }}
    {{- with .Values.controller.rollingUpdate }}
      {{- if and (eq $strategy "RollingUpdate") (or .surge .unavailable) }}
    rollingUpdate:
        {{- with .unavailable }}
      maxUnavailable: {{ . }}
        {{- end }}
        {{- with .surge }}
      maxSurge: {{ . }}
        {{- end }}
      {{- end }}
    {{- end }}
  selector:
    matchLabels:
      {{- include "tc.common.v10.labels.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
      {{- include "tc.common.v10.annotations.workload.spec" . | nindent 8 }}
      {{- with .Values.podAnnotations }}
        {{- tpl ( toYaml . ) $ | nindent 8 }}
      {{- end }}
      labels:
        {{- include "tc.common.v10.labels.selectorLabels" . | nindent 8 }}
        {{- with .Values.podLabels }}
        {{- tpl ( toYaml . ) $ | nindent 8 }}
        {{- end }}
    spec:
      {{- include "tc.common.v10.controller.pod" . | nindent 6 }}
{{- end }}
