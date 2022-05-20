{{/*
This template serves as a blueprint for all secret objects that are created
within the common library.
*/}}
{{- define "common.class.secret" -}}
  {{- $fullName := include "common.names.fullname" . -}}
  {{- $secretName := $fullName -}}
  {{- $values := .Values.secret -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.secret -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $secretName = printf "%v-%v" $secretName $values.nameOverride -}}
  {{- end }}
---
apiVersion: v1
kind: secret
metadata:
  name: {{ $secretName }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with $values.labels }}
       {{- tpl ( toYaml . ) $ | nindent 4 }}
    {{- end }}
  {{- with $values.annotations }}
  annotations:
    {{- tpl ( toYaml . ) $ | nindent 4 }}
  {{- end }}
stringData:
{{- with $values.data }}
  {{- tpl (toYaml .) $ | nindent 2 }}
{{- end }}
{{- end }}
