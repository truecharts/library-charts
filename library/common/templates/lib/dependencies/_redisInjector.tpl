{{/*
This template generates a random password and ensures it persists across updates/edits to the chart
*/}}
{{- define "tc.v1.common.dependencies.redis.secret" -}}
{{- $dbHost := printf "%v-%v" .Release.Name "redis" -}}

{{- if .Values.redis.enabled -}}
  {{/* Initialize variables */}}
  {{- $basename := include "tc.v1.common.lib.chart.names.fullname" $ -}}
  {{- $fetchname := printf "%s-rediscreds" $basename -}}
  {{- $dbprevious := lookup "v1" "Secret" .Release.Namespace $fetchname -}}
  {{- $dbPass := randAlphaNum 50 -}}
  {{- $dbIndex := .Values.redis.redisDatabase | default "0" -}}

  {{/* If there are previous secrets, fetch values and decrypt them */}}
  {{- if $dbprevious -}}
    {{- $dbPass = (index $dbprevious.data "redis-password") | b64dec -}}
  {{- end -}}

  {{/* Append some values to mariadb.creds, so apps using the dep, can use them */}}
  {{- $_ := set .Values.redis.creds "redisPassword" ($dbPass | quote) -}}
  {{- $_ := set .Values.redis.creds "plain" ($dbHost | quote) -}}
  {{- $_ := set .Values.redis.creds "plainhost" ((printf "%v" $dbHost) | quote) -}}
  {{- $_ := set .Values.redis.creds "plainport" ((printf "%v:6379" $dbHost) | quote) -}}
  {{- $_ := set .Values.redis.creds "plainporthost" ((printf "%v:6379" $dbHost) | quote) -}}

{{/* Create the secret (Comment also plays a role on correct formatting) */}}
enabled: true
expandObjectName: false
data:
  redis-password: {{ $dbPass }}
  plain: {{ $dbHost }}
  url: {{ (printf "redis://%v:%v@%v:6379/%v" .Values.redis.redisUsername $dbPass $dbHost $dbIndex) }}
  plainhostpass: {{ (printf "%v:%v@%v" .Values.redis.redisUsername $dbPass $dbHost) }}
  plainporthost: {{ (printf "%v:6379" $dbHost) }}
  plainhost: {{ $dbHost }}
  {{- end -}}
{{- end -}}

{{- define "tc.v1.common.dependencies.redis.injector" -}}
  {{- $secret := include "tc.v1.common.dependencies.redis.secret" . | fromYaml -}}
  {{- if $secret -}}
    {{- $_ := set .Values.secret (printf "%s-%s" .Release.Name "rediscreds") $secret -}}
  {{- end -}}
{{- end -}}
