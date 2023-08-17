{{- define "tc.v1.common.class.cnpg.pooler" -}}
  {{- $values := .Values.cnpg -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.cnpg -}}
      {{- $values = . -}}
    {{- end -}}
  {{- end -}}
  {{- $cnpgClusterName := $values.name -}}
  {{- $cnpgName := $values.cnpgName -}}
  {{- $cnpgPoolerName := $values.poolerName -}}
  {{- $cnpgLabels := $values.labels -}}
  {{- $cnpgAnnotations := $values.annotations -}}
  {{- $cnpgPoolerLabels := $values.pooler.labels -}}
  {{- $cnpgPoolerAnnotations := $values.pooler.annotations -}}
  {{- $instances := $values.pooler.instances | default 2 -}}
  {{- $hibernation := false -}}
  {{- if or $values.hibernate $.Values.global.stopAll -}}
    {{- $instances = 0 -}}
    {{- $hibernation = true -}}
  {{- end }}
  {{- $type := $values.pooler.type | default "rw" -}}
---
apiVersion: {{ include "tc.v1.common.capabilities.cnpg.pooler.apiVersion" $ }}
kind: Pooler
metadata:
  name: {{ printf "%v-%v" $cnpgClusterName $type }}
  namespace: {{ $.Values.namespace | default $.Values.global.namespace | default $.Release.Namespace }}
  {{- $labels := (mustMerge ($cnpgPoolerLabels | default dict) ($cnpgLabels | default dict) (include "tc.v1.common.lib.metadata.allLabels" $ | fromYaml)) }}
  labels:
    cnpg.io/reload: "on"
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $ "labels" $labels) | trim) }}
    {{- . | nindent 4 }}
  {{- end }}
  {{- $annotations := (mustMerge ($cnpgPoolerAnnotations | default dict) ($cnpgLabels | default dict) (include "tc.v1.common.lib.metadata.allAnnotations" $ | fromYaml)) }}
  annotations:
    rollme: {{ randAlphaNum 5 | quote }}
    cnpg.io/hibernation: {{ $hibernation | quote }}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $ "annotations" $annotations) | trim) }}
    {{- . | nindent 4 }}
  {{- end }}
spec:
  cluster:
    name: {{ $cnpgClusterName }}
  instances: {{ $instances }}
  type: {{ $type }}
  pgbouncer:
    poolMode: {{ $values.pooler.poolMode | default "session" }}
    parameters:
      {{- if not $values.pooler.parameters.max_client_conn -}}
      max_client_conn: "1000"
      {{- end -}}
      {{- if  not $values.pooler.parameters.default_pool_size -}}
      default_pool_size: "10"
      {{- end -}}
      {{- $values.pooler.parameters | toYaml | nindent 6 }}
{{- end -}}
