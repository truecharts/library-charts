{{/*
This template serves as the blueprint for the DaemonSet objects that are created
within the common library.
*/}}
{{- define "common.daemonset" }}
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: {{ include "common.names.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with .Values.controller.labels }}
      {{- tpl ( toYaml . ) $ | nindent 4 }}
    {{- end }}
  annotations:
  {{- include "common.annotations.workload" . | nindent 4 }}
  {{- with .Values.controller.annotations }}
    {{- tpl ( toYaml . ) $ | nindent 4 }}
  {{- end }}
spec:
  revisionHistoryLimit: {{ .Values.controller.revisionHistoryLimit }}
  selector:
    matchLabels:
      {{- include "common.labels.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
      {{- include "common.annotations.workload.spec" . | nindent 8 }}
      {{- with .Values.podAnnotations }}
        {{- tpl ( toYaml . ) $ | nindent 8 }}
      {{- end }}
      labels:
        {{- include "common.labels.selectorLabels" . | nindent 8 }}
        {{- with .Values.podLabels }}
        {{- tpl ( toYaml . ) $ | nindent 8 }}
        {{- end }}
    spec:
      {{- include "common.controller.pod" . | nindent 6 }}
{{- end }}
