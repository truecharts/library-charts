{{/*
The Tailscale sidecar container to be inserted.
*/}}
{{- define "tc.common.addon.tailscale.container" -}}
name: tailscale
image: "{{ .Values.tailscaleImage.repository }}:{{ .Values.tailscaleImage.tag }}"
imagePullPolicy: {{ .Values.tailscaleImage.pullPolicy }}

command: ["ash", "/tailscale/run.sh"]

tty: true

securityContext:
  runAsUser: 568
  runAsGroup: 568

serviceAccount:
  main:
    create: true

rbac:
  main:
    enabled: true
    rules:
      - apiGroups:
          - ""
        resources:
          - "secrets"
        verbs:
          - "create"
      - apiGroups:
          - ""
        resources:
          - "secrets"
        resourceNames:
          - '{{ printf "%s-tailscale-secret" (include "tc.common.names.fullname" .) }}'
        verbs:
          - "get"
          - "update"

env:
    {{- $secretName := printf "%s-tailscale-secret" (include "tc.common.names.fullname" .) }}
  - name: TS_KUBE_SECRET
    value: {{ $secretName | squote }}
  - name: TS_USERSPACE
    value: {{ .Values.addons.vpn.tailscale.userspace | quote }}
  - name: TS_ACCEPT_DNS
    value: {{ .Values.addons.vpn.tailscale.accept_dns | quote }}
    {{- with .Values.addons.vpn.tailscale.routes }}
  - name: TS_ROUTES
    value: {{ . }}
    {{- end }}
    {{- with .Values.addons.vpn.tailscale.dest_ip }}
  - name: TS_DEST_IP
    value: {{ . }}
    {{- end }}
    {{- with .Values.addons.vpn.tailscale.extra_args }}
  - name: TS_EXTRA_ARGS
    value: {{ . | quote }}
    {{- end }}

{{- range $envList := .Values.addons.vpn.envList }}
  {{- if and $envList.name $envList.value }}
  - name: {{ $envList.name }}
    value: {{ $envList.value | quote }}
  {{- else }}
  {{- fail "Please specify name/value for VPN environment variable" }}
  {{- end }}
{{- end}}

{{- with .Values.addons.vpn.env }}
{{- range $k, $v := . }}
  - name: {{ $k }}
    value: {{ $v | quote }}
{{- end }}
{{- end }}

{{- if .Values.addons.vpn.killSwitch }}
  - name: KILLSWITCH
    value: "true"
  {{- $excludednetworksv4 := "172.16.0.0/12"}}
  {{- range .Values.addons.vpn.excludedNetworks_IPv4 }}
    {{- $excludednetworksv4 =  ( printf "%v;%v" $excludednetworksv4 . ) }}
  {{- end}}
  - name: KILLSWITCH_EXCLUDEDNETWORKS_IPV4
    value: {{ $excludednetworksv4 | quote }}
{{- if .Values.addons.vpn.excludedNetworks_IPv6 }}
  {{- $excludednetworksv6 := ""}}
  {{- range .Values.addons.vpn.excludedNetworks_IPv4 }}
    {{- $excludednetworksv6 =  ( printf "%v;%v" $excludednetworksv6 . ) }}
  {{- end}}
  - name: KILLSWITCH_EXCLUDEDNETWORKS_IPV6
    value: {{ .Values.addons.vpn.excludedNetworks_IPv6 | quote }}
{{- end }}
{{- end }}

volumeMounts:
  - mountPath: {{ .Values.persistence.shared.mountPath }}
    name: shared
{{- with .Values.addons.vpn.livenessProbe }}
livenessProbe:
  {{- toYaml . | nindent 2 }}
{{- end -}}
{{- with .Values.addons.vpn.resources }}
resources:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}
