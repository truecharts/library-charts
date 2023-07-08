{{/*
This template serves as a blueprint for all Cert-Manager Certificate objects that are created
within the common library.
*/}}
{{- define "tc.v1.common.class.certificate" -}}
{{- $root := .root -}}
{{- $name := .name -}}
{{- $hosts := .hosts -}}
{{- $certificateIssuer := .certificateIssuer }}
---
apiVersion: {{ include "tc.v1.common.capabilities.cert-manager.certificate.apiVersion" $ }}
kind: Certificate
metadata:
  name: {{ $name }}
  namespace: {{ include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $rootCtx "objectData" $objectData "caller" "Cert Manager Certificate") }}
spec:
  secretName: {{ $name }}
  dnsNames:
  {{- range $hosts }}
  - {{ tpl . $root | quote }}
  {{- end }}
  privateKey:
    algorithm: ECDSA
    size: 256
    rotationPolicy: Always
  issuerRef:
    name: {{ tpl $certificateIssuer $root | quote }}
    kind: ClusterIssuer
    group: cert-manager.io


{{- end -}}
