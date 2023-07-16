{{- define "tc.v1.common.lib.webhook.admissionReviewVersions" -}}
  {{- $admissionReviewVersions := .admissionReviewVersions }}
admissionReviewVersions:
  {{- range $admissionReviewVersions }}
  - {{ . }}
  {{- end -}}
{{- end -}}
