{{- define "tc.v1.common.lib.util.tcnamespace" -}}
---
apiVersion: v1
kind: Namespace
metadata:
  name: tc-system
  annotations:
    "helm.sh/resource-policy": keep
{{- end -}}
