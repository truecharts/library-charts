{{/* Ingress Class */}}
{{/* Call this template:
{{ include "tc.v1.common.class.ingress" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the chart.
objectData: The object data to be used to render the Ingress.
*/}}

{{- define "tc.v1.common.class.ingress" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{/* TODO: fetch the selected service or fallback to primary */}}

  {{- if not (hasKey $objectData "integrations") -}}
    {{- $_ := set $objectData "integrations" dict -}}
  {{- end -}}
  {{- if not (hasKey $objectData "annotations") -}}
    {{- $_ := set $objectData "annotations" dict -}}
  {{- end -}}

  {{- include "tc.v1.common.lib.ingress.integration.certManager" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
  {{- include "tc.v1.common.lib.ingress.integration.traefik" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
  {{- include "tc.v1.common.lib.ingress.integration.homepage" (dict "rootCtx" $rootCtx "objectData" $objectData) }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $objectData.name }}
  namespace: {{ include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $rootCtx "objectData" $objectData "caller" "Ingress") }}
  {{- $labels := (mustMerge ($objectData.labels | default dict) (include "tc.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- $annotations := (mustMerge ($objectData.annotations | default dict) (include "tc.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
spec:
  {{- /* TODO: UT */}}
  {{- if $objectData.ingressClassName }}
  ingressClassName: {{ $objectData.ingressClassName }}
  {{- end }}
  rules:
    {{- range $h := $objectData.hosts }}
    - host: {{ $h.host }}
      http:
        paths:
          {{- range $p := $h.paths -}}
            {{- $serviceName := "TODO:!" -}}
            {{- $servicePort := "TODO:!" -}}
            {{- with $p.overrideService -}}
              {{- $serviceName = .name -}}
              {{- $servicePort = .port -}}
            {{- end }}
          - path: {{ $p.path }}
            pathType: {{ $p.pathType | default "Prefix" }}
            backend:
              service:
                name: {{ $serviceName }}
                port:
                  number: {{ $servicePort }}
          {{- end -}}
    {{- end }}


{{- end -}}
