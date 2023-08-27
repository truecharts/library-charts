{{- define "tc.v1.common.class.cnpg.pooler" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $cnpgClusterName := $objectData.name -}}

  {{- if and $objectData.version (ne $objectData.version "legacy") -}}
    {{- $cnpgClusterName = printf "%v-%v" $objectData.name $objectData.version -}}
  {{- end -}}

  {{- if $objectData.recValue -}}
    {{- $cnpgClusterName = printf "%v-%v" $cnpgClusterName $objectData.recValue -}}
  {{- end -}}

  {{- $cnpgLabels := $objectData.labels -}}
  {{- $cnpgAnnotations := $objectData.annotations -}}
  {{- $cnpgPoolerLabels := $objectData.pooler.labels -}}
  {{- $cnpgPoolerAnnotations := $objectData.pooler.annotations -}}
  {{- $instances := $objectData.pooler.instances | default 2 -}}
  {{- $hibernation := "off" -}}
  {{- if or $objectData.hibernate $rootCtx.Values.global.stopAll -}}
    {{- $instances = 0 -}}
    {{- $hibernation = "on" -}}
  {{- end -}}
  {{- $type := $objectData.pooler.type | default "rw" }}
---
apiVersion: {{ include "tc.v1.common.capabilities.cnpg.pooler.apiVersion" $rootCtx }}
kind: Pooler
metadata:
  name: {{ printf "%v-pooler-%v" $objectData.name $type }}
  namespace: {{ include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $rootCtx "objectData" $objectData "caller" "CNPG Pooler") }}
  labels:
    cnpg.io/reload: "on"
  {{- $labels := (mustMerge ($cnpgPoolerLabels | default dict) ($cnpgLabels | default dict) (include "tc.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
    {{- . | nindent 4 }}
  {{- end -}}
  annotations:
    rollme: {{ randAlphaNum 5 | quote }}
    cnpg.io/hibernation: {{ $hibernation | quote }}
  {{- $annotations := (mustMerge ($cnpgPoolerAnnotations | default dict) ($cnpgAnnotations | default dict) (include "tc.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
    {{- . | nindent 4 }}
  {{- end }}
spec:
  cluster:
    name: {{ $cnpgClusterName }}
  instances: {{ $instances }}
  type: {{ $type }}
  pgbouncer:
    poolMode: {{ $objectData.pooler.poolMode | default "session" }}
    {{- with $objectData.pooler.parameters | default dict -}}
    parameters:
      {{- . | toYaml | nindent 6 }}
    {{ end }}
{{- end -}}
