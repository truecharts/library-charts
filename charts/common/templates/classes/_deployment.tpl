{{/*
This template serves as the blueprint for the Deployment objects that are created
within the common library.
*/}}
{{- define "common.class.deployment" }}
{{- $values := .Values.pod -}}
{{- if hasKey . "ObjectValues" -}}
  {{- with .ObjectValues.pod -}}
    {{- $values = . -}}
  {{- end -}}
{{ end -}}

{{- $podName := include "common.names.fullname" . -}}
{{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
  {{- $podName = printf "%v-%v" $podName $values.nameOverride -}}
{{ end -}}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $podName }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with $values.labels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  annotations:
  {{- include "common.annotations.workload" . | nindent 4 }}
  {{- with $values.annotations }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  revisionHistoryLimit: {{ $values.revisionHistoryLimit }}
  replicas: {{ $values.replicas }}
  {{- $strategy := default "Recreate" $values.strategy }}
  {{- if and (ne $strategy "Recreate") (ne $strategy "RollingUpdate") }}
    {{- fail (printf "Not a valid strategy type for Deployment (%s)" $strategy) }}
  {{- end }}
  strategy:
    type: {{ $strategy }}
    {{- with $values.rollingUpdate }}
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
      {{- include "common.labels.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
      {{- include "common.annotations.workload.spec" . | nindent 8 }}
      {{- with .Values.pod.annotations }}
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "common.labels.selectorLabels" . | nindent 8 }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- include "common.lib.pod" $ | nindent 6 }}
{{- end }}
