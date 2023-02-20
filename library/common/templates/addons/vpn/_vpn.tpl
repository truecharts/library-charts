{{/*
Template to render VPN addon
It will include / inject the required templates based on the given values.
*/}}
{{- define "tc.v1.common.addon.vpn" -}}
{{- if ne "disabled" .Values.addons.vpn.type -}}

  {{- if .Values.addons.vpn.config -}}
    {{/* Append the vpn config secret to the secrets */}}
    {{- $secret := include "tc.v1.common.addon.vpn.secret" . | fromYaml -}}
    {{- if $secret -}}
      {{- $_ := set .Values.secret "vpnconfig" $secret -}}
    {{- end -}}
  {{- end }}

  {{- if or .Values.addons.vpn.scripts.up .Values.addons.vpn.scripts.down -}}
    {{/* Append the vpn up/down scripts to the configmaps */}}
    {{- $configmap := include "tc.v1.common.addon.vpn.configmap" . | fromYaml -}}
    {{- if $configmap -}}
      {{- $_ := set .Values.secret "vpnscripts" $configmap -}}
    {{- end -}}
  {{- end }}

  {{- if or .Values.addons.vpn.configFile .Values.addons.vpn.config .Values.addons.vpn.configSecret -}}
    {{/* Append the vpn config to the persistence */}}
    {{- $configper := include "tc.v1.common.addon.vpn.volume.config" . | fromYaml -}}
    {{- if $configper -}}
      {{- $_ := set .Values.persistence "vpnconfig" $configper -}}
    {{- end -}}
  {{- end -}}

  {{- if or .Values.addons.vpn.scripts.up .Values.addons.vpn.scripts.down -}}
    {{/* Append the vpn scripts to the persistence */}}
    {{- $scriptsper := include "tc.v1.common.addon.vpn.volume.scripts" . | fromYaml -}}
    {{- if $scriptsper -}}
      {{- $_ := set .Values.persistence "vpnscripts" $scriptsper -}}
    {{- end -}}
  {{- end -}}

  {{- if or .Values.addons.vpn.configFolder -}}
    {{/* Append the vpn folder to the persistence */}}
    {{- $folderper := include "tc.v1.common.addon.vpn.volume.scripts" . | fromYaml -}}
    {{- if $folderper -}}
      {{- $_ := set .Values.persistence "vpnfolder" $folderper -}}
    {{- end -}}
  {{- end -}}


  {{- if eq "gluetun" .Values.addons.vpn.type -}}
    {{/* Append the code-server container to the additionalContainers */}}
    {{- $containers := include "tc.v1.common.addon.vpn.gluetun.containers" . | fromYaml -}}
    {{- if $containers -}}
      {{- $newworkloads := merge $.Values.workload $containers }}
      {{- $_ := set $.Values "workload" $newworkloads -}}
    {{- end -}}
  {{- else if ( eq "tailscale" .Values.addons.vpn.type ) -}}
    {{/* Append the code-server container to the additionalContainers */}}
    {{- $containers := include "tc.v1.common.addon.vpn.tailscale.containers" . | fromYaml -}}
    {{- if $containers -}}
      {{- $newworkloads := merge $.Values.workload $containers }}
      {{- $_ := set $.Values "workload" $newworkloads -}}
    {{- end -}}

    {{/* Append the empty tailscale folder to the persistence */}}
    {{- $tailscaleper := include "tc.v1.common.addon.vpn.volume.tailscale" . | fromYaml -}}
    {{- if $tailscaleper -}}
      {{- $_ := set .Values.persistence "tailscale" $tailscaleper -}}
    {{- end -}}
  {{- end -}}



{{- end -}}
{{- end -}}
