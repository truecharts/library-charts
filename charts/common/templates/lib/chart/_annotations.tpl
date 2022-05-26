{{/* Common annotations shared across objects */}}
{{- define "tc.common.v10.annotations" -}}
  {{- with .Values.global.annotations }}
    {{- range $k, $v := . }}
      {{- $name := $k }}
      {{- $value := tpl $v $ }}
{{ $name }}: {{ quote $value }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/* Annotations on all workload spec objects */}}
{{- define "tc.common.v10.annotations.workload.spec" -}}
{{- if .Values.ixExternalInterfacesConfigurationNames }}
k8s.v1.cni.cncf.io/networks: {{ join ", " .Values.ixExternalInterfacesConfigurationNames }}
{{- end }}
{{- end -}}

{{/* Annotations on all workload objects */}}
{{- define "tc.common.v10.annotations.workload" -}}
{{- end -}}
