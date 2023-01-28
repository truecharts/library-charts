{{/* Return the name of the primary redis object */}}
{{- define "tc.v1.common.lib.util.redis.primary" -}}
  {{- $rediss := .Values.redis -}}

  {{- $enabledredises := dict -}}
  {{- range $name, $redis := $rediss -}}
    {{- if $redis.enabled -}}
      {{- $_ := set $enabledredises $name . -}}
    {{- end -}}
  {{- end -}}

  {{- $result := "" -}}
  {{- range $name, $redis := $enabledredises -}}
    {{- if and (hasKey $redis "primary") $redis.primary -}}
      {{- $result = $name -}}
    {{- end -}}
  {{- end -}}

  {{- if not $result -}}
    {{- $result = keys $enabledredises | first -}}
  {{- end -}}
  {{- $result -}}
{{- end -}}
