{{/*
This template serves as a blueprint for rbac objects that are created
using the common library.
*/}}
{{- define "common.class.rbac" -}}
  {{- $targetName := include "common.names.fullname" . }}
  {{- $fullName := include "common.names.fullname" . -}}
  {{- $rbacName := $fullName -}}
  {{- $values := .Values.rbac -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.rbac -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $rbacName = printf "%v-%v" $rbacName $values.nameOverride -}}
  {{- end }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ $rbacName }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with $values.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  annotations:
    {{- with $values.annotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
{{- with $values.rules }}
rules:
  {{- . | toYaml | nindent 4 }}
{{- end}}

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ $rbacName }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with $values.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  annotations:
    {{- with $values.annotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: {{ $rbacName }}
subjects:
  {{- if $values.subjects }}
  {{- with $values.subjects }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- else }}
  - kind: ServiceAccount
    name: {{ default (include "common.names.serviceAccountName" .) $values.serviceAccount.name }}
    namespace: {{ .Release.Namespace }}
  {{- end }}
{{- end -}}
