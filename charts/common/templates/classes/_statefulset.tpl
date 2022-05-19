{{/*
This template serves as the blueprint for the StatefulSet objects that are created
within the common library.
*/}}
{{- define "common.class.statefulset" }}
{{- $values := .Values }}
{{- $releaseName := .Release.Name }}
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
kind: StatefulSet
metadata:
  name: {{ $podName }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with $values.labels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $values.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  revisionHistoryLimit: {{ $values.revisionHistoryLimit }}
  replicas: {{ $values.replicas }}
  {{- $strategy := default "RollingUpdate" $values.strategy }}
  {{- if and (ne $strategy "OnDelete") (ne $strategy "RollingUpdate") }}
    {{- fail (printf "Not a valid strategy type for StatefulSet (%s)" $strategy) }}
  {{- end }}
  updateStrategy:
    type: {{ $strategy }}
    {{- if and (eq $strategy "RollingUpdate") $values.rollingUpdate.partition }}
    rollingUpdate:
      partition: {{ $values.rollingUpdate.partition }}
    {{- end }}
  selector:
    matchLabels:
      {{- include "common.labels.selectorLabels" . | nindent 6 }}
  serviceName: {{ include "common.names.fullname" . }}
  template:
    metadata:
      {{- with .Values.pod.annotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "common.labels.selectorLabels" . | nindent 8 }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- include "ccommon.lib.pod" . | nindent 6 }}
  volumeClaimTemplates:
    {{- range $index, $vct := .Values.volumeClaimTemplates }}
    {{- $vctname := $index }}
    {{- if $vct.name }}
    {{- $vctname := $vct.name }}
    {{- end }}
    - metadata:
        name: {{ $vctname }}
      spec:
        accessModes:
          - {{ ( $vct.accessMode | default "ReadWriteOnce" ) | quote }}
        resources:
          requests:
            storage: {{ $vct.size | default "999Gi" | quote }}
        {{ include "common.storage.class" ( dict "persistence" $vct "global" $) }}
    {{- end }}
{{- end }}
