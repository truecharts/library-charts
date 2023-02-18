{{/*
Template to render gluetun addon. It will add a container to the main pod.
*/}}
*/}}
{{- define ""tc.v1.common.addon.vpn.gluetun" -}}
  {{/* Append the code-server container to the additionalContainers */}}
  {{- $container := include "tc.v1.common.addon.vpn.gluetun.container" . | fromYaml -}}
  {{- if $container -}}
    {{- $_ := set .Values.workload.main.podSpec.containers "vpn" $container -}}
  {{- end -}}
{{- end -}}
