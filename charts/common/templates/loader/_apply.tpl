{{/*
Secondary entrypoint and primary loader for the common chart
*/}}
{{- define "tc.common.v10.loader.apply" -}}
  {{- /* Render the externalInterfaces */ -}}
  {{ include "tc.common.v10.scale.externalInterfaces" .  | nindent 0 }}

  {{- /* Enable code-server add-on if required */ -}}
  {{- if .Values.addons.codeserver.enabled }}
    {{- include "tc.common.v10.addon.codeserver" . }}
  {{- end -}}

  {{- /* Enable VPN add-on if required */ -}}
  {{- if ne "disabled" .Values.addons.vpn.type -}}
    {{- include "tc.common.v10.addon.vpn" . }}
  {{- end -}}

  {{- /* Enable promtail add-on if required */ -}}
  {{- if .Values.addons.promtail.enabled }}
    {{- include "tc.common.v10.addon.promtail" . }}
  {{- end -}}

  {{- /* Enable netshoot add-on if required */ -}}
  {{- if .Values.addons.netshoot.enabled }}
    {{- include "tc.common.v10.addon.netshoot" . }}
  {{- end -}}

  {{- /* Build the configmaps */ -}}
  {{ include "tc.common.v10.spawner.configmap" . | nindent 0 }}

  {{- /* Build the secrets */ -}}
  {{ include "tc.common.v10.spawner.secret" . | nindent 0 }}

  {{- /* Build the templates */ -}}
  {{- include "tc.common.v10.spawner.pvc" . }}

  {{ include "tc.common.v10.spawner.serviceaccount" . | nindent 0 }}

  {{- if .Values.controller.enabled }}
    {{- if eq .Values.controller.type "deployment" }}
      {{- include "tc.common.v10.deployment" . | nindent 0 }}
    {{ else if eq .Values.controller.type "daemonset" }}
      {{- include "tc.common.v10.daemonset" . | nindent 0 }}
    {{ else if eq .Values.controller.type "statefulset"  }}
      {{- include "tc.common.v10.statefulset" . | nindent 0 }}
    {{ else }}
      {{- fail (printf "Not a valid controller.type (%s)" .Values.controller.type) }}
    {{- end -}}
 {{- end -}}

  {{ include "tc.common.v10.spawner.rbac" . | nindent 0 }}

  {{ include "tc.common.v10.spawner.hpa" . | nindent 0 }}

  {{ include "tc.common.v10.spawner.service" . | nindent 0 }}

  {{ include "tc.common.v10.spawner.ingress" .  | nindent 0 }}

  {{ include "tc.common.v10.scale.portal" .  | nindent 0 }}

  {{ include "tc.common.v10.spawner.networkpolicy" . | nindent 0 }}
{{- end -}}
