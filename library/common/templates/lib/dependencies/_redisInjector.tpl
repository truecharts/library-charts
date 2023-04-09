{{/*
This template generates a random password and ensures it persists across updates/edits to the chart
*/}}
{{- define "tc.v1.common.dependencies.redis.secret" -}}
{{- $fullname := include "tc.v1.common.lib.chart.names.fullname" $ }}
{{- $name := ( printf "%s-rediscreds" $fullname ) }}

{{- if .Values.redis.enabled }}
enabled: true
expandObjectName: false
{{- $basename := include "tc.v1.common.lib.chart.names.fullname" $ -}}
{{- $fetchname := printf "%s-rediscreds" $basename -}}
{{- $dbprevious := lookup "v1" "Secret" .Release.Namespace $fetchname }}
{{- $dbPass := "" }}
{{- $dbIndex := default "0" .Values.redis.redisDatabase }}
data:
{{- if $dbprevious }}
  {{- $dbPass = ( index $dbprevious.data "redis-password" ) | b64dec  }}
{{- else }}
  {{- $dbPass = randAlphaNum 50 }}
{{- end }}
  redis-password: {{ $dbPass }}
  plain: {{ printf "%v-%v" .Release.Name "redis" }}
  url: {{ ( printf "redis://%v:%v@%v-redis:6379/%v" .Values.redis.redisUsername $dbPass .Release.Name $dbIndex ) }}
  plainhostpass: {{ ( printf "%v:%v@%v-redis" .Values.redis.redisUsername $dbPass .Release.Name ) }}
  plainporthost: {{ ( printf "%v-%v:6379" .Release.Name "redis" ) }}
  plainhost: {{ ( printf "%v-%v" .Release.Name "redis" ) }}
type: Opaque
{{- $_ := set .Values.redis.creds "redisPassword" ( $dbPass | quote ) }}
{{- $_ := set .Values.redis.creds "plain" ( ( printf "%v-%v" .Release.Name "redis" ) | quote ) }}
{{- $_ := set .Values.redis.creds "plainhost" ( ( printf "%v-%v" .Release.Name "redis" ) | quote ) }}
{{- $_ := set .Values.redis.creds "plainport" ( ( printf "%v-%v:6379" .Release.Name "redis" ) | quote ) }}
{{- $_ := set .Values.redis.creds "plainporthost" ( ( printf "%v-%v:6379" .Release.Name "redis" ) | quote ) }}

{{- end }}
{{- end -}}

{{- define "tc.v1.common.dependencies.redis.injector" -}}
  {{- $secret := include "tc.v1.common.dependencies.redis.secret" . | fromYaml -}}
  {{- if $secret -}}
    {{- $_ := set .Values.secret ( printf "%s-%s" .Release.Name "rediscreds" ) $secret -}}
  {{- end -}}
{{- end -}}