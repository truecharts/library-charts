{{/*
Template to render VPN addon
It will include / inject the required templates based on the given values.
*/}}
{{- define "tc.v1.common.addon.vpn" -}}
{{- if ne "disabled" .Values.addons.vpn.type -}}

  {{- if eq "gluetun" .Values.addons.vpn.type -}}
    {{- include "tc.v1.common.addon.gluetun" . }}
  {{- end -}}

  {{- if eq "tailscale" .Values.addons.vpn.type -}}
    {{- include "tc.v1.common.addon.tailscale" . }}
  {{- end -}}

{{- end -}}
{{- end -}}
