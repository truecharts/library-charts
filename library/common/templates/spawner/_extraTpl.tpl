{{- define "tc.v1.common.spawner.extraTpl" -}}
{{- range .Values.extraTpl }}
---
{{- if typeIs "string" . }}
    {{- tpl . $ | nindent 0 }}
{{- else }}
    {{- tpl (. | toYaml) $ | nindent 0 }}
{{- end }}
{{- end }}
{{- end }}
