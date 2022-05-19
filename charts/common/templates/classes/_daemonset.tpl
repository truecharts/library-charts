{{/*
This template serves as the blueprint for the DaemonSet objects that are created
within the common library.
*/}}
{{- define "common.class.daemonset" }}
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
kind: DaemonSet
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
