{{/*
This template generates a random password and ensures it persists across updates/edits to the chart
*/}}
{{- define "tc.v1.common.dependencies.mongodb.secret" -}}
{{- $dbhost := printf "%v-%v" .Release.Name "mongodb" }}

{{- if .Values.mongodb.enabled -}}
  {{/* Initialize variables */}}
  {{- $basename := include "tc.v1.common.lib.chart.names.fullname" $ -}}
  {{- $fetchname := printf "%s-mongodbcreds" $basename -}}
  {{- $dbprevious := lookup "v1" "Secret" .Release.Namespace $fetchname -}}
  {{- $dbpreviousold := lookup "v1" "Secret" .Release.Namespace "mongodbcreds" -}}
  {{- $dbPass := randAlphaNum 50 -}}
  {{- $rootPass := randAlphaNum 50 -}}

  {{/* If there are previous secrets, fetch values and decrypt them */}}
  {{- if $dbprevious -}}
    {{- $dbPass = (index $dbprevious.data "mongodb-password") | b64dec -}}
    {{- $rootPass = (index $dbprevious.data "mongodb-root-password") | b64dec -}}
  {{- else if $dbpreviousold -}}
    {{- $dbPass = (index $dbpreviousold.data "mongodb-password") | b64dec -}}
    {{- $rootPass = (index $dbpreviousold.data "mongodb-root-password") | b64dec -}}
  {{- end -}}
  {{/* Append some values to mariadb.creds, so apps using the dep, can use them */}}
  {{- $_ := set .Values.mongodb.creds "mongodbPassword" ($dbPass | quote) -}}
  {{- $_ := set .Values.mongodb.creds "mongodbRootPassword" ($rootPass | quote) -}}
  {{- $_ := set .Values.mongodb.creds "plain" ($dbhost | quote) -}}
  {{- $_ := set .Values.mongodb.creds "plainhost" ($dbhost | quote) -}}
  {{- $_ := set .Values.mongodb.creds "plainport" ((printf "%v:27017" $dbhost) | quote) -}}
  {{- $_ := set .Values.mongodb.creds "plainporthost" ((printf "%v:27017" $dbhost) | quote) -}}
  {{- $_ := set .Values.mongodb.creds "complete" ((printf "mongodb://%v:%v@%v:27017/%v" .Values.mongodb.mongodbUsername $dbPass $dbhost .Values.mongodb.mongodbDatabase) | quote) -}}
  {{- $_ := set .Values.mongodb.creds "jdbc" ((printf "jdbc:mongodb://%v:27017/%v" $dbhost .Values.mongodb.mongodbDatabase) | quote) -}}

{{/* Create the secret (Comment also plays a role on correct formatting) */}}
enabled: true
expandObjectName: false
data:
  mongodb-password: {{ $dbPass }}
  mongodb-root-password: {{ $rootPass }}
  url: {{ (printf "mongodb://%v:%v@%v:27017/%v" .Values.mongodb.mongodbUsername $dbPass $dbhost .Values.mongodb.mongodbDatabase) }}
  urlssl: {{ (printf "mongodb://%v:%v@%v:27017/%v?ssl=true" .Values.mongodb.mongodbUsername $dbPass $dbhost .Values.mongodb.mongodbDatabase) }}
  urltls: {{ (printf "mongodb://%v:%v@%v:27017/%v?tls=true" .Values.mongodb.mongodbUsername $dbPass $dbhost .Values.mongodb.mongodbDatabase) }}
  jdbc: {{ (printf "jdbc:mongodb://%v:27017/%v" $dbhost .Values.mongodb.mongodbDatabase) }}
  plainhost: {{ $dbhost }}
  plainporthost: {{ (printf "%v:27017" $dbhost) }}
  {{- end -}}
{{- end -}}

{{- define "tc.v1.common.dependencies.mongodb.injector" -}}
  {{- $secret := include "tc.v1.common.dependencies.mongodb.secret" . | fromYaml -}}
  {{- if $secret -}}
    {{- $_ := set .Values.secret (printf "%s-%s" .Release.Name "mongodbcreds") $secret -}}
  {{- end -}}
{{- end -}}
