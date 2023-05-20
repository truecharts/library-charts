{{- define "tc.v1.common.lib.util.tcnamespace" -}}
  {{- if $.Values.global.createTCNamespace }}
---
apiVersion: v1
kind: Namespace
metadata:
  name: tc-system
  annotations:
    "helm.sh/resource-policy": keep
  {{- end -}}
{{- end -}}
