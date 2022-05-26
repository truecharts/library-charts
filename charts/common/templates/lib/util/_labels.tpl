{{/* vim: set filetype=mustache: */}}
{{/*
Kubernetes standard labels
*/}}
{{- define "tc.common.v10.labels.standard" -}}
{{- include "tc.common.v10.labels" . }}
{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
*/}}
{{- define "tc.common.v10.labels.matchLabels" -}}
{{- include "tc.common.v10.labels.selectorLabels" . }}
{{- end -}}
