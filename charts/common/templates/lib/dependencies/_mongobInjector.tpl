{{/*
This template generates a random password and ensures it persists across updates/edits to the chart
*/}}
{{- define "common.dependencies.mongodb.injector" -}}
{{- $pghost := printf "%v-%v" .Release.Name "mongodb" }}

{{- if .Values.mongodb.enabled }}
---
apiVersion: v1
kind: Secret
metadata:
  labels:
    {{- include "common.labels" . | nindent 4 }}
  name: mongodbcreds
{{- $dbprevious := lookup "v1" "Secret" .Release.Namespace "mongodbcreds" }}
{{- $dbPass := "" }}
{{- $rootPass := "" }}
data:
{{- if $dbprevious }}
  {{- $dbPass = ( index $dbprevious.data "mongodb-password" ) | b64dec  }}
  {{- $rootPass = ( index $dbprevious.data "mongodb-root-password" ) | b64dec  }}
  mongodb-password: {{ ( index $dbprevious.data "mongodb-password" ) }}
  mongodb-root-password: {{ ( index $dbprevious.data "mongodb-root-password" ) }}
{{- else }}
  {{- $dbPass = randAlphaNum 50 }}
  {{- $rootPass = randAlphaNum 50 }}
  mongodb-password: {{ $dbPass | b64enc | quote }}
  mongodb-root-password: {{ $rootPass | b64enc | quote }}
{{- end }}
  # url: {{ ( printf "sql://%v:%v@%v-mongodb:3306/%v" .Values.mongodb.mongodbUsername $dbPass .Release.Name .Values.mongodb.mongodbDatabase  ) | b64enc | quote }}
  # urlnossl: {{ ( printf "sql://%v:%v@%v-mongodb:3306/%v?sslmode=disable" .Values.mongodb.mongodbUsername $dbPass .Release.Name .Values.mongodb.mongodbDatabase  ) | b64enc | quote }}
  # plainporthost: {{ ( printf "%v-%v:3306" .Release.Name "mongodb" ) | b64enc | quote }}
  # plainhost: {{ ( printf "%v-%v" .Release.Name "mongodb" ) | b64enc | quote }}
  # jdbc: {{ ( printf "jdbc:sqlserver://%v-mongodb:3306/%v" .Release.Name .Values.mongodb.mongodbDatabase  ) | b64enc | quote }}
  # jdbc-mysql: {{ ( printf "jdbc:mysql://%v-mongodb:3306/%v" .Release.Name .Values.mongodb.mongodbDatabase  ) | b64enc | quote }}
  # jdbc-mongodb: {{ ( printf "jdbc:mongodb://%v-mongodb:3306/%v" .Release.Name .Values.mongodb.mongodbDatabase  ) | b64enc | quote }}
type: Opaque
# {{- $_ := set .Values.mongodb "mongodbPassword" ( $dbPass | quote ) }}
# {{- $_ := set .Values.mongodb "mongodbRootPassword" ( $rootPass | quote ) }}
# {{- $_ := set .Values.mongodb.url "plain" ( ( printf "%v-%v" .Release.Name "mongodb" ) | quote ) }}
# {{- $_ := set .Values.mongodb.url "plainhost" ( ( printf "%v-%v" .Release.Name "mongodb" ) | quote ) }}
# {{- $_ := set .Values.mongodb.url "plainport" ( ( printf "%v-%v:3306" .Release.Name "mongodb" ) | quote ) }}
# {{- $_ := set .Values.mongodb.url "plainporthost" ( ( printf "%v-%v:3306" .Release.Name "mongodb" ) | quote ) }}
# {{- $_ := set .Values.mongodb.url "complete" ( ( printf "sql://%v:%v@%v-mongodb:3306/%v" .Values.mongodb.mongodbUsername $dbPass .Release.Name .Values.mongodb.mongodbDatabase  ) | quote ) }}
# {{- $_ := set .Values.mongodb.url "jdbc" ( ( printf "jdbc:sqlserver://%v-mongodb:3306/%v" .Release.Name .Values.mongodb.mongodbDatabase  ) | quote ) }}

{{- end }}
{{- end -}}
