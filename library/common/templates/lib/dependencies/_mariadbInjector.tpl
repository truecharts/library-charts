{{/*
This template generates a random password and ensures it persists across updates/edits to the chart
*/}}
{{- define "tc.v1.common.dependencies.mariadb.secret" -}}
{{- $dbhost := printf "%v-%v" .Release.Name "mariadb" -}}

{{- if .Values.mariadb.enabled -}}
  {{/* Initialize variables */}}
  {{- $basename := include "tc.v1.common.lib.chart.names.fullname" $ -}}
  {{- $fetchname := printf "%s-mariadbcreds" $basename -}}
  {{- $dbprevious := lookup "v1" "Secret" .Release.Namespace $fetchname -}}
  {{- $dbpreviousold := lookup "v1" "Secret" .Release.Namespace "mariadbcreds" -}}
  {{- $dbPass := randAlphaNum 50 -}}
  {{- $rootPass := randAlphaNum 50 -}}

  {{/* If there are previous secrets, fetch values and decrypt them */}}
  {{- if $dbprevious -}}
    {{- $dbPass = (index $dbprevious.data "mariadb-password") | b64dec -}}
    {{- $rootPass = (index $dbprevious.data "mariadb-root-password") | b64dec -}}
  {{- else if $dbpreviousold -}}
    {{- $dbPass = (index $dbpreviousold.data "mariadb-password") | b64dec -}}
    {{- $rootPass = (index $dbpreviousold.data "mariadb-root-password") | b64dec -}}
  {{- end -}}

  {{/* Append some values to mariadb.creds, so apps using the dep, can use them */}}
  {{- $_ := set .Values.mariadb.creds "mariadbPassword" ($dbPass | quote) -}}
  {{- $_ := set .Values.mariadb.creds "mariadbRootPassword" ($rootPass | quote) -}}
  {{- $_ := set .Values.mariadb.creds "plain" ((printf "%v" $dbhost) | quote) -}}
  {{- $_ := set .Values.mariadb.creds "plainhost" ((printf "%v" $dbhost) | quote) -}}
  {{- $_ := set .Values.mariadb.creds "plainport" ((printf "%v:3306" $dbhost) | quote) -}}
  {{- $_ := set .Values.mariadb.creds "plainporthost" ((printf "%v:3306" $dbhost) | quote) -}}
  {{- $_ := set .Values.mariadb.creds "complete" ((printf "sql://%v:%v@%v:3306/%v" .Values.mariadb.mariadbUsername $dbPass $dbhost .Values.mariadb.mariadbDatabase) | quote) -}}
  {{- $_ := set .Values.mariadb.creds "jdbc" ((printf "jdbc:sqlserver://%v:3306/%v" $dbhost .Values.mariadb.mariadbDatabase) | quote) -}}

{{/* Create the secret (Comment also plays a role on correct formatting) */}}
enabled: true
expandObjectName: false
data:
  mariadb-password: {{ $dbPass }}
  mariadb-root-password: {{ $rootPass }}
  url: {{ (printf "sql://%v:%v@%v:3306/%v" .Values.mariadb.mariadbUsername $dbPass $dbhost .Values.mariadb.mariadbDatabase) }}
  urlnossl: {{ (printf "sql://%v:%v@%v:3306/%v?sslmode=disable" .Values.mariadb.mariadbUsername $dbPass $dbhost .Values.mariadb.mariadbDatabase) }}
  plainporthost: {{ (printf "%v:3306" $dbhost) }}
  plainhost: {{ (printf "%v" $dbhost) }}
  jdbc: {{ (printf "jdbc:sqlserver://%v:3306/%v" $dbhost .Values.mariadb.mariadbDatabase) }}
  jdbc-mysql: {{ (printf "jdbc:mysql://%v:3306/%v" $dbhost .Values.mariadb.mariadbDatabase) }}
  jdbc-mariadb: {{ (printf "jdbc:mariadb://%v:3306/%v" $dbhost .Values.mariadb.mariadbDatabase) }}
  {{- end -}}
{{- end -}}

{{- define "tc.v1.common.dependencies.mariadb.injector" -}}
  {{- $secret := include "tc.v1.common.dependencies.mariadb.secret" . | fromYaml -}}
  {{- if $secret -}}
    {{- $_ := set .Values.secret (printf "%s-%s" .Release.Name "mariadbcreds") $secret -}}
  {{- end -}}
{{- end -}}
