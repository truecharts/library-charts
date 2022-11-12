{{/*
This template serves as a blueprint for all cnpg objects that are created
within the common library.
*/}}
{{- define "tc.common.class.cnpg" -}}
{{- $values := .Values.cnpg -}}
{{- if hasKey . "ObjectValues" -}}
  {{- with .ObjectValues.cnpg -}}
    {{- $values = . -}}
  {{- end -}}
{{ end -}}

{{- $cnpgName := include "tc.common.names.fullname" . -}}
{{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
  {{- $cnpgName = printf "%v-%v" $cnpgName $values.nameOverride -}}
{{ end -}}
{{- $svcType := $values.type | default "" -}}
{{- $primaryPort := get $values.ports (include "tc.common.lib.util.cnpg.ports.primary" (dict "values" $values)) }}
---
apiVersion: v1
kind: cnpg
metadata:
  name: {{ $cnpgName }}
  {{- with (merge ($values.labels | default dict) (include "tc.common.labels" $ | fromYaml)) }}
  labels: {{- tpl ( toYaml . ) $ | nindent 4 }}
  {{- end }}
  annotations:
  {{- with (merge ($values.annotations | default dict) (include "tc.common.annotations" $ | fromYaml)) }}
    {{- tpl ( toYaml . ) $ | nindent 4 }}
  {{- end }}

{{- end }}
