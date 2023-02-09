{{/* Service - MetalLB Annotations */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.service.metalLBAnnotations" (dict "rootCtx" $rootCtx "objectData" $objectData "annotations" $annotations) -}}
rootCtx: The root context of the service
objectData: The object data of the service
annotations: The annotations variable reference, to append the MetalLB annotations
*/}}

{{- define "ix.v1.common.lib.service.metalLBAnnotations" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}
  {{- $annotations := .annotations -}}

  {{- $sharedKey := include "ix.v1.common.lib.chart.names.fullname" $rootCtx -}}

  {{/* A custom shared key can be defined per service even between multiple charts */}}
  {{- with $objectData.sharedKey -}}
    {{- $sharedKey = tpl . $rootCtx -}}
  {{- end -}}

  {{- if $rootCtx.Values.global.addMetalLBAnnotations -}}
    {{- $_ := set $annotations "metallb.universe.tf/allow-shared-ip" $sharedKey -}}
  {{- end -}}
{{- end -}}

{{/* Service - Traefik Annotations */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.service.traefikAnnotations" (dict "rootCtx" $rootCtx "annotations" $annotations) -}}
rootCtx: The root context of the service
annotations: The annotations variable reference, to append the Traefik annotations
*/}}

{{- define "ix.v1.common.lib.service.traefikAnnotations" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $annotations := .annotations -}}

  {{- if $rootCtx.Values.global.addTraefikAnnotations -}}
    {{- $_ := set $annotations "traefik.ingress.kubernetes.io/service.serversscheme" "https" -}}
  {{- end -}}
{{- end -}}
