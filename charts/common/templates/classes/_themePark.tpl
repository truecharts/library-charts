{{- define "common.classes.themePark" -}}
{{- if .Values.addons.themePark.enabled -}}

{{- $appName := .Chart.Name -}}
{{- $themeName := .Values.addons.themePark.themeName -}}

---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: theme
spec:
  plugin:
    themePark:
      app: {{ $appName }}
      theme: {{ $themeName }}

{{- end -}}
{{- end }}
