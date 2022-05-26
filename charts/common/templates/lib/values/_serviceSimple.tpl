{{/* Allow some extra "fake" service options for SCALE GUI simplification */}}
{{- define "tc.common.v10.lib.values.service.simple" -}}
  {{- range .Values.service }}
  {{- if .type }}
  {{- if eq .type "Simple" }}
  {{- $_ := set . "type" "LoadBalancer" }}
  {{- end }}
  {{- end }}
  {{- end }}
{{- end -}}
