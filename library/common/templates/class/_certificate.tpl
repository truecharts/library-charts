{{/*
This template serves as a blueprint for all Cert-Manager Certificate objects that are created
within the common library.
*/}}
{{- define "tc.v1.common.class.certificate" -}}
  {{- $fullName := include "ix.v1.common.names.fullname" . -}}
  {{- $ingressName := $fullName -}}
  {{- $name := .name -}}
  {{- $hosts := .hosts -}}
  {{- $certificateIssuer := .certificateIssuer -}}
---
apiVersion: {{ include "tc.v1.common.capabilities.cert-manager.certificate.apiVersion" $ }}
kind: Certificate
metadata:
  name: {{ $name }}
spec:
  secretName: {{ $name }}
  dnsNames:
  {{- range $hosts }}
  - {{ tpl . $ | quote }}
  {{- end }}
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: {{ tpl $certificateIssuer $ | quote }}
    kind: ClusterIssuer
    group: cert-manager.io


{{- end -}}
