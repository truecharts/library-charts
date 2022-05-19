{{/*
This template serves as a blueprint for ServiceAccount objects that are created
using the common library.
*/}}
{{- define "common.class.serviceaccount" -}}
  {{- $targetName := include "common.names.fullname" . }}
  {{- $fullName := include "common.names.fullname" . -}}
  {{- $saName := $fullName -}}
  {{- $values := .Values.serviceAccount -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.serviceAccount -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $saName = printf "%v-%v" $saName $values.nameOverride -}}
  {{- end }}

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $saName }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with $values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
