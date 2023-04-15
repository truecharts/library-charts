{{/*
The gluetun sidecar container to be inserted.
*/}}
{{- define "tc.v1.common.addon.vpn.wireguard.container" -}}
enabled: true
imageSelector: wireguardImage
probes:
{{- if $.Values.addons.vpn.livenessProbe }}
  liveness:
  {{- toYaml . | nindent 2 }}
{{- else }}
  liveness:
    enabled: false
{{- end }}
  readiness:
    enabled: false
  startup:
    enabled: false
securityContext:
  runAsUser: 568
  runAsGroup: 568
  capabilities:
    add:
      - NET_ADMIN
      - NET_RAW
      - SETUID
      - SETGID
      - SYS_MODULE

{{- with $.Values.addons.vpn.env }}
env:
  {{- . | toYaml | nindent 2 }}
{{- end }}
  SEPARATOR: ";"
  IPTABLES_BACKEND: "nft"
{{- if .Values.addons.vpn.killSwitch }}
  KILLSWITCH: "true"
  {{- $excludednetworksv4 := "172.16.0.0/12" -}}
  {{- range .Values.addons.vpn.excludedNetworks_IPv4 -}}
    {{- $excludednetworksv4 = ( printf "%v;%v" $excludednetworksv4 . ) -}}
  {{- end }}
  KILLSWITCH_EXCLUDEDNETWORKS_IPV4: {{ $excludednetworksv4 | quote }}
{{- if .Values.addons.vpn.excludedNetworks_IPv6 -}}
  {{- $excludednetworksv6 := "" -}}
  {{- range .Values.addons.vpn.excludedNetworks_IPv4 -}}
    {{- $excludednetworksv6 = ( printf "%v;%v" $excludednetworksv6 . ) -}}
  {{- end }}
  KILLSWITCH_EXCLUDEDNETWORKS_IPV6: {{ .Values.addons.vpn.excludedNetworks_IPv6 | quote }}
{{- end -}}
{{- end -}}

{{- range $envList := $.Values.addons.vpn.envList -}}
  {{- if and $envList.name $envList.value }}
  {{ $envList.name }}: {{ $envList.value | quote }}
  {{- else -}}
    {{- fail "Please specify name/value for VPN environment variable" -}}
  {{- end -}}
{{- end -}}

{{- with $.Values.addons.vpn.args }}
args:
  {{- . | toYaml | nindent 2 }}
{{- end -}}
{{- end -}}
