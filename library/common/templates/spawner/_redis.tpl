{{/* Renders the redis objects required by the chart */}}
{{- define "tc.v1.common.spawner.redis" -}}
  {{/* Generate named redises as required */}}
  {{- range $name, $redis := .Values.redis -}}
    {{- if $redis.enabled -}}
      {{- $redisValues := $redis -}}
      {{- $redisName := include "ix.v1.common.names.fullname" $ -}}

      {{/* set defaults */}}
      {{- if and (not $redisValues.nameOverride) (ne $name (include "tc.v1.common.lib.util.redis.primary" $)) -}}
        {{- $_ := set $redisValues "nameOverride" $name -}}
      {{- end -}}

      {{- if $redisValues.nameOverride -}}
        {{- $redisName = printf "%v-%v" $redisName $redisValues.nameOverride -}}
      {{- end -}}

      {{- $redisName = printf "redis-%v" $redisName -}}

      {{- $_ := set $redisValues "name" $redisName -}}

      {{- include "tc.v1.common.class.redis.pooler" $ -}}

    {{- end -}}
  {{- end -}}
{{- end -}}
