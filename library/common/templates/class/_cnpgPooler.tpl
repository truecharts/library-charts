{{- define "tc.v1.common.class.cnpg.pooler" -}}
  {{- $values := .Values.cnpg -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.cnpg -}}
      {{- $values = . -}}
    {{- end -}}
  {{- end -}}

  {{- $cnpgClusterName := $values.name -}}
  {{- if and $cnpg.version ( ne $cnpg.version "legacy" ) -}}
    {{- $cnpgClusterName = printf "$v-%v" $values.name $values.version -}}
  {{- end -}}

  {{- $cnpgName := $values.cnpgName -}}
  {{- $cnpgPoolerName := $values.poolerName -}}
  {{- $cnpgLabels := $values.labels -}}
  {{- $cnpgAnnotations := $values.annotations -}}
  {{- $cnpgPoolerLabels := $values.pooler.labels -}}
  {{- $cnpgPoolerAnnotations := $values.pooler.annotations -}}
  {{- $instances := $values.pooler.instances | default 2 -}}
  {{- $hibernation := "off" -}}
  {{- if or $values.hibernate $.Values.global.stopAll -}}
    {{- $instances = 0 -}}
    {{- $hibernation = "on" -}}
  {{- end }}
  {{- $type := $values.pooler.type | default "rw" -}}
---
apiVersion: {{ include "tc.v1.common.capabilities.cnpg.pooler.apiVersion" $ }}
kind: Pooler
metadata:
  name: {{ printf "%v-pooler-%v" $cnpgClusterName $type }}
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
    {{- $parameters := $values.pooler.parameters | default dict -}}
    {{- with $parameters -}}
    parameters:
      {{- . | toYaml | nindent 6 }}
    {{ end }}
{{- end -}}
