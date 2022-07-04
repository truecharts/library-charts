{{/*
  This template generates a random password and ensures it persists across updates/edits to the chart
*/}}
{{- define "tc.common.dependencies.clickhouse.injector" -}}
{{- if .Values.clickhouse.enabled }}

{{- $secretName := "clickhousecreds" }}

{{- $dbPass := "" }}
{{- with (lookup "v1" "Secret" .Release.Namespace $secretName) }}
  {{- $dbPass = index .stringData "clickhouse-password" }}
{{- else }}
  {{- $dbPass = randAlphaNum 50 }}
{{- end }}

{{- $host     := printf              "%v-clickhouse"         .Release.Name }}
{{- $portHost := printf              "%v-clickhouse:8123"    .Release.Name }}
{{- $url      := printf "http://%v:%v@%v-clickhouse:8123/%v" .Values.clickhouse.clickhouseUsername $dbPass .Release.Name .Values.clickhouse.clickhouseDatabase }}
{{- $jdbc     := printf    "jdbc:ch://%v-clickhouse:8123/%v" .Release.Name }}
---
apiVersion: v1
kind: Secret
metadata:
  labels:
    {{- include "tc.common.labels" . | nindent 4 }}
  name: {{ $secretName }}
stringData:
  clickhouse-password: {{ $dbPass | quote }}
  plainhost:           {{ $host | quote }}
  plainporthost:       {{ $portHost | quote }}
  url:                 {{ $url | quote }}
  jdbc:                {{ $jdbc | quote }}

{{- $_ := set .Values.clickhouse     "clickhousePassword" ($dbPass | quote) }}
{{- $_ := set .Values.clickhouse.url "plain"              ($host | quote) }}
{{- $_ := set .Values.clickhouse.url "plainhost"          ($host | quote) }}
{{- $_ := set .Values.clickhouse.url "plainport"          ($portHost | quote) }}
{{- $_ := set .Values.clickhouse.url "plainporthost"      ($portHost  | quote) }}
{{- $_ := set .Values.clickhouse.url "complete"           ($url | quote) }}
{{- $_ := set .Values.clickhouse.url "jdbc"               ($jdbc | quote) }}

{{- end }}
{{- end -}}
