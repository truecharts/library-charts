{{/* Enable privileged securitycontext when deviceList is used */}}
{{- define "tc.common.v10.lib.values.securityContext.privileged" -}}
  {{- if .Values.securityContext.privileged }}
  {{- else if .Values.deviceList }}
  {{- $_ := set .Values.securityContext "privileged" true -}}
  {{- $_ := set .Values.securityContext "allowPrivilegeEscalation" true -}}
  {{- end }}
{{- end -}}
