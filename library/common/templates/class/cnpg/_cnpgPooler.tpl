{{- define "tc.v1.common.class.cnpg.pooler" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{/* Naming */}}
  {{- $poolerName := printf "%s-pooler-%s" $objectData.name $objectData.pooler.type -}}
  {{- $cnpgClusterName := (include "tc.v1.common.lib.cnpg.clusterName" (dict "objectData" $objectData)) -}}

  {{/* Metadata */}}
  {{- $objLabels := $objectData.labels | default dict -}}
  {{- $poolerLabels := $objectData.pooler.labels | default dict -}}
  {{- $poolerLabels = mustMerge $poolerLabels $objLabels -}}

  {{- $objAnnotations := $objectData.annotations | default dict -}}
  {{- $poolerAnnotations := $objectData.pooler.annotations | default dict -}}
  {{- $poolerAnnotations = mustMerge $poolerAnnotations $objAnnotations -}}

  {{/* Stop All */}}
  {{- $instances := $objectData.pooler.instances | default 2 -}}
  {{- $hibernation := "off" -}}
  {{- if or $objectData.hibernate (include "tc.v1.common.lib.util.stopAll" $rootCtx) -}}
    {{- $instances = 0 -}}
    {{- $hibernation = "on" -}}
  {{- end }}
---
apiVersion: postgresql.cnpg.io/v1
kind: Pooler
metadata:
  name: {{ $poolerName }}
  namespace: {{ include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $rootCtx "objectData" $objectData "caller" "CNPG Pooler") }}
  labels:
    cnpg.io/reload: "on"
  {{- $labels := (mustMerge $poolerLabels (include "tc.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
    {{- . | nindent 4 }}
  {{- end }}
  annotations:
    rollme: {{ randAlphaNum 5 | quote }}
    cnpg.io/hibernation: {{ $hibernation | quote }}
  {{- $annotations := (mustMerge $poolerAnnotations (include "tc.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
    {{- . | nindent 4 }}
  {{- end }}
spec:
  cluster:
    name: {{ $cnpgClusterName }}
  instances: {{ $instances }}
  type: {{ $objectData.pooler.type }}
  pgbouncer:
    poolMode: {{ $objectData.pooler.poolMode | default "session" }}
    {{/* https://cloudnative-pg.io/documentation/1.15/connection_pooling/#pgbouncer-configuration-options */}}
    {{- with $objectData.pooler.parameters }}
    parameters:
      {{- range $key, $value := . }}
      {{ $key }}: {{ $value | quote }}
      {{- end -}}
    {{- end -}}
{{- end -}}
