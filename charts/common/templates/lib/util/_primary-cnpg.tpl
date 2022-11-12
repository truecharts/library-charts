{{/*
Return the primary cnpg object
*/}}
{{- define "tc.common.lib.util.cnpg.primary" -}}
  {{- $enabledcnpgs := dict -}}
  {{- range $name, $cnpg := .Values.cnpg -}}
    {{- if $cnpg.enabled -}}
      {{- $_ := set $enabledcnpgs $name . -}}
    {{- end -}}
  {{- end -}}

  {{- $result := "" -}}
  {{- range $name, $cnpg := $enabledcnpgs -}}
    {{- if and (hasKey $cnpg "primary") $cnpg.primary -}}
      {{- $result = $name -}}
    {{- end -}}
  {{- end -}}

  {{- if not $result -}}
    {{- $result = keys $enabledcnpgs | first -}}
  {{- end -}}
  {{- $result -}}
{{- end -}}
