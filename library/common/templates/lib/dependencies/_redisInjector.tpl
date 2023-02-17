{{/*
This template generates a random password and ensures it persists across updates/edits to the chart
*/}}
{{- define "tc.v1.common.dependencies.redis.secret" -}}
{{- $fullname := include "tc.v1.common.lib.chart.names.fullname" $ }}
{{- $name := ( printf "%s-rediscreds" $fullname ) }}

{{- if .Values.redis.enabled }}
enabled: true
{{- $dbprevious := lookup "v1" "Secret" .Release.Namespace $name }}
{{- $dbPass := "" }}
{{- $dbIndex := default "0" .Values.redis.redisDatabase }}
data:
{{- if $dbprevious }}
  {{- $dbPass = ( index $dbprevious.data "redis-password" ) | b64dec  }}
  redis-password: {{ ( index $dbprevious.data "redis-password" ) }}
{{- else }}
  {{- $dbPass = randAlphaNum 50 }}
  redis-password: {{ $dbPass | b64enc | quote }}
{{- end }}
  url: {{ ( printf "redis://%v:%v@%v-redis:6379/%v" .Values.redis.redisUsername $dbPass .Release.Name $dbIndex ) | b64enc | quote }}
  plainhostpass: {{ ( printf "%v:%v@%v-redis" .Values.redis.redisUsername $dbPass .Release.Name ) | b64enc | quote }}
  plainporthost: {{ ( printf "%v-%v:6379" .Release.Name "redis" ) | b64enc | quote }}
  plainhost: {{ ( printf "%v-%v" .Release.Name "redis" ) | b64enc | quote }}
type: Opaque
{{- $_ := set .Values.redis "redisPassword" ( $dbPass | quote ) }}
{{- $_ := set .Values.redis.url "plain" ( ( printf "%v-%v" .Release.Name "redis" ) | quote ) }}
{{- $_ := set .Values.redis.url "plainhost" ( ( printf "%v-%v" .Release.Name "redis" ) | quote ) }}
{{- $_ := set .Values.redis.url "plainport" ( ( printf "%v-%v:6379" .Release.Name "redis" ) | quote ) }}
{{- $_ := set .Values.redis.url "plainporthost" ( ( printf "%v-%v:6379" .Release.Name "redis" ) | quote ) }}

{{- end }}
{{- end -}}

{{- define "tc.v1.common.dependencies.redis.injector" -}}
  {{- $secret := include "tc.v1.common.dependencies.redis.secret" . | fromYaml -}}
  {{- if $secret -}}
    {{- $_ := set .Values.secret "rediscreds" $secret -}}
  {{- end -}}
{{- end -}}
