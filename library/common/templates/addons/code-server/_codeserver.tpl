{{/*
Template to render code-server addon
It will include / inject the required templates based on the given values.
*/}}
{{- define "tc.v1.common.addon.codeserver" -}}
{{- if .Values.addons.codeserver.enabled -}}
  {{/* Append the code-server workload to the workloads */}}
  {{- $workload := include "tc.v1.common.addon.codeserver.workload" . | fromYaml -}}
  {{- if $workload -}}
    {{- $_ := set $.Values.workload "codeserver" $workload -}}
  {{- end -}}

  {{/* Add the code-server service */}}
  {{- if .Values.addons.codeserver.service.enabled -}}
    {{- $serviceValues := .Values.addons.codeserver.service -}}
    {{- $_ := set $serviceValues "targetPort" 12321 -}}
    {{- $_ := set $serviceValues "targetSelector" "codeserver" -}}
    {{- $_ := set .Values.service "codeserver" $serviceValues -}}
  {{- end -}}


  {{/* Add the code-server ingress */}}
  {{- if .Values.addons.codeserver.ingress.enabled -}}
    {{- $ingressValues := .Values.addons.codeserver.ingress -}}
    {{- $_ := set $ingressValues "nameOverride" "codeserver" -}}

    {{/* Determine the target service name & port */}}
    {{- $svcName := printf "%v-codeserver" (include "tc.v1.common.names.fullname" .) -}}
    {{- $svcPort := .Values.addons.codeserver.service.ports.codeserver.port -}}
    {{- range $_, $host := $ingressValues.hosts -}}
      {{- $_ := set (index $host.paths 0) "service" (dict "name" $svcName "port" $svcPort) -}}
    {{- end -}}
    {{- $_ := set $ "ObjectValues" (dict "ingress" $ingressValues) -}}
    {{- include "tc.v1.common.class.ingress" $ -}}
    {{- $_ := unset $ "ObjectValues" -}}
  {{- end -}}
{{- end -}}
{{- end -}}
