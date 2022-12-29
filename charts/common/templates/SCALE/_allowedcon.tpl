{{- define "tc.common.scale.allowedcon" -}}
---
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: allowedCon
  {{- with (include "tc.common.labels" $ | fromYaml) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (include "tc.common.annotations" $ | fromYaml) }}
  annotations:
    {{- tpl ( toYaml . ) $ | nindent 4 }}
  {{- end }}
spec:
  podSelector: {}
  policyTypes: ["Ingress"]
  ingress:
  - from:
    - namespaceSelector:
         matchLabels:
          kubernetes.io/metadata.name: metallb-system
    {{- range .Values.allowedCon }}
    - namespaceSelector:
         matchLabels:
          kubernetes.io/metadata.name: {{ . }}
    {{- end -}}
{{- end -}}
