{{/*
Return the primary pod object
*/}}
{{- define "common.helper.pod.primary" -}}
  {{- $enabledPods := dict -}}
  {{- range $name, $pod := .Values.pod -}}
    {{- if $pod.enabled -}}
      {{- $_ := set $enabledPods $name . -}}
    {{- end -}}
  {{- end -}}

  {{- $result := "" -}}
  {{- range $name, $pod := $enabledPods -}}
    {{- if and (hasKey $pod "primary") $pod.primary -}}
      {{- $result = $name -}}
    {{- end -}}
  {{- end -}}

  {{- if not $result -}}
    {{- $result = keys $enabledPods | first -}}
  {{- end -}}
  {{- $result -}}
{{- end -}}
