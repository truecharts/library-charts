{{- define "tc.v1.common.lib.util.operator.verify" -}}
{{- if .Values.operator.verify.enabled }}

{{- range .Values.operator.verify.additionalOperators -}}
  {{ $operator := lookup "v1" "ConfigMap" "tc-system" . }}
  {{ if not $operator }}
    {{- fail ( printf "The following Operator needs to be installed: %s" . ) }}
  {{ end }}
{{ end }}

{{- end }}
{{- end -}}
