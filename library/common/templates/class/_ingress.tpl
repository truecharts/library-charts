{{/* Ingress Class */}}
{{/* Call this template:
{{ include "tc.v1.common.class.ingress" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the chart.
objectData: The object data to be used to render the Ingress.
*/}}

{{- define "tc.v1.common.class.ingress" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- /* TODO: UT */}}
  {{- $svcData := (include "tc.v1.common.lib.ingress.targetSelector" (dict "rootCtx" $rootCtx "objectData" $objectData) | fromYaml) -}}

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
  {{- if $objectData.ingressClassName }}
  ingressClassName: {{ tpl $objectData.ingressClassName $rootCtx }}
  {{- end }}
  rules:
    {{- range $h := $objectData.hosts }}
    - host: {{ tpl $h.host $rootCtx }}
      http:
        paths:
          {{- range $p := $h.paths -}}
            {{- with $p.overrideService -}}
              {{- $svcData = (dict "name" .name "port" .port) -}}
            {{- end }}
          - path: {{ tpl $p.path $rootCtx }}
            pathType: {{ tpl ($p.pathType | default "Prefix") $rootCtx }}
            backend:
              service:
                name: {{ $svcData.name }}
                port:
                  number: {{ $svcData.port }}
          {{- end -}}
    {{- end -}}
  {{/* If a clusterIssuer is defined in the whole ingress, use that */}}
  {{- if and $objectData.integrations.certManager $objectData.integrations.certManager.enabled -}}
    {{- $clusterIssuer := $objectData.integrations.certManager.clusterIssuer }}
  tls:
    {{- range $h := $objectData.hosts }}
    - secretName: TODO:!!!
      hosts:
        - {{ tpl $h.host $rootCtx }}
    {{- end -}}
  {{- else if $objectData.tls }} {{/* If a tls is defined in the tls section, use that */}}
  tls:
    {{- range $t := $objectData.tls -}}
    - secretName: TODO:!!!
      hosts:
        {{- range $h := $t.hosts }}
        - {{ tpl $h $rootCtx }}
        {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
