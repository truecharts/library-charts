{{/* Return the name of the primary ingress object */}}
{{- define "tc.v1.common.lib.util.ingress.primary" -}}
  {{- $ingresses := $.Values.ingress -}}

  {{- $enabledIngresses := dict -}}
  {{- range $name, $ingress := $ingresses -}}
    {{- if $ingress.enabled -}}
      {{- $_ := set $enabledIngresses $name . -}}
      {{- if $ingress.corsEnabled -}}
        {{- $newMiddlewares :=  list "tc-opencors-chain" }}
        {{- $_ := set .Values.ingress.main "fixedMiddlewares" $newMiddlewares -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $result := "" -}}
  {{- range $name, $ingress := $enabledIngresses -}}
    {{- if and (hasKey $ingress "primary") $ingress.primary -}}
      {{- $result = $name -}}
    {{- end -}}
  {{- end -}}

  {{- if not $result -}}
    {{- $result = keys $enabledIngresses | first -}}
  {{- end -}}
  {{- $result -}}
{{- end -}}
