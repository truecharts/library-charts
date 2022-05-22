{{/* Common annotations shared across objects */}}
{{- define "common.annotations" -}}
  {{- with .Values.global.annotations }}
    {{- range $k, $v := . }}
      {{- $name := $k }}
      {{- $value := tpl $v $ }}
{{ $name }}: {{ quote $value }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/* Annotations on all workload spec objects */}}
{{- define "common.annotations.workload.spec" -}}
rollme: {{ randAlphaNum 5 | quote }}
{{- if .Values.ixExternalInterfacesConfigurationNames }}
(include "common.annotations" $ | fromYaml))
k8s.v1.cni.cncf.io/networks: {{ join ", " .Values.ixExternalInterfacesConfigurationNames }}
{{- end }}
{{- end -}}

{{/* Annotations on all workload objects */}}
{{- define "common.annotations.workload" -}}
(include "common.annotations" $ | fromYaml))
rollme: {{ randAlphaNum 5 | quote }}
{{- end -}}
