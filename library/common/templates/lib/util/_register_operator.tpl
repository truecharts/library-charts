{{- define "tc.v1.common.lib.util.operator.register" -}}
{{- if .Values.operator.register }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $.Chart.Name }}
  {{- $labels := (include "tc.v1.common.lib.metadata.allLabels" $ | fromYaml) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $ "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- $annotations := (include "tc.v1.common.lib.metadata.allAnnotations" $ | fromYaml) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $ "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
  namespace: tc-system
data:
  {{/* The namespace the operator is installed in */}}
  namespace: {{ $.Release.Namespace }}
  {{/* The version of the installed operator */}}
  version: {{ $.Chart.Version }}
{{- end }}
{{- end -}}
