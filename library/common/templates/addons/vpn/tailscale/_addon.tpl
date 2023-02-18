{{/*
Template to render Tailscale addon. It will add the container to the list of additionalContainers.
*/}}

{{- define "tc.v1.common.addon.vpn.tailscale" -}}
  {{/* Append the code-server container to the additionalContainers */}}
  {{- $container := include "tc.v1.common.addon.vpn.tailscale.container" . | fromYaml -}}
  {{- if $container -}}
    {{- $_ := set .Values.workload.main.podSpec.containers "vpn" $container -}}
  {{- end -}}
{{- end -}}
