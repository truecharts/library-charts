{{- define "tc.v1.common.spawner.extraTpl" -}}
{{- range .Values.extraTpl }}
---
{{- if typeIs "string" . }}
    {{- tpl . $ }}
{{- else }}
    {{- tpl (. | toYaml) $ }}
{{- end }}
{{- end }}
