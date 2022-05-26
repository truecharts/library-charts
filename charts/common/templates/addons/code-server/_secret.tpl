{{/*
The OpenVPN credentials secrets to be included.
*/}}
{{- define "tc.common.v10.addon.codeserver.deployKeySecret" -}}
{{- if or .Values.addons.codeserver.git.deployKey .Values.addons.codeserver.git.deployKeyBase64 }}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ template "tc.common.v10.names.fullname" . }}-deploykey
  labels:
    {{- include "tc.common.v10.labels" . | nindent 4 }}
type: Opaque
{{- if .Values.addons.codeserver.git.deployKey }}
stringData:
  id_rsa: {{ .Values.addons.codeserver.git.deployKey | quote }}
{{- else }}
data:
  id_rsa: {{ .Values.addons.codeserver.git.deployKeyBase64 | quote }}
{{- end }}
{{- end }}
{{- end -}}
