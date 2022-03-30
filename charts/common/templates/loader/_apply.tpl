{{/*
Secondary entrypoint and primary loader for the common chart
*/}}
{{- define "common.loader.apply" -}}
  {{- /* Render the externalInterfaces */ -}}
  {{ include "common.SCALE.externalInterfaces" .  | nindent 0 }}

  {{- /* Enable code-server add-on if required */ -}}
  {{- if .Values.addons.codeserver.enabled }}
    {{- include "common.addon.codeserver" . }}
  {{- end -}}

  {{- /* Enable VPN add-on if required */ -}}
  {{- if ne "disabled" .Values.addons.vpn.type -}}
    {{- include "common.addon.vpn" . }}
  {{- end -}}

  {{- /* Enable promtail add-on if required */ -}}
  {{- if .Values.addons.promtail.enabled }}
    {{- include "common.addon.promtail" . }}
  {{- end -}}

  {{- /* Enable netshoot add-on if required */ -}}
  {{- if .Values.addons.netshoot.enabled }}
    {{- include "common.addon.netshoot" . }}
  {{- end -}}

  {{- /* Build the configmaps */ -}}
  {{ include "common.spawner.configmap" . | nindent 0 }}

  {{- /* Build the secrets */ -}}
  {{ include "common.spawner.secret" . | nindent 0 }}

  {{- /* Build the templates */ -}}
  {{- include "common.spawner.pvc" . }}

  {{- include "common.serviceAccount" . }}

  {{- if .Values.controller.enabled }}
    {{- if eq .Values.controller.type "deployment" }}
      {{- include "common.deployment" . | nindent 0 }}
    {{ else if eq .Values.controller.type "daemonset" }}
      {{- include "common.daemonset" . | nindent 0 }}
    {{ else if eq .Values.controller.type "statefulset"  }}
      {{- include "common.statefulset" . | nindent 0 }}
    {{ else }}
      {{- fail (printf "Not a valid controller.type (%s)" .Values.controller.type) }}
    {{- end -}}
 {{- end -}}

  {{ include "common.rbac" . | nindent 0 }}

  {{ include "common.spawner.hpa" . | nindent 0 }}

  {{ include "common.spawner.service" . | nindent 0 }}

  {{ include "common.spawner.ingress" .  | nindent 0 }}

  {{ include "common.configmap.portal" .  | nindent 0 }}

  {{ include "common.spawner.networkpolicy" . | nindent 0 }}
{{- end -}}
