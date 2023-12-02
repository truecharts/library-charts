{{- define "tc.v1.common.class.cnpg.scheduledbackup" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{/* Naming */}}
  {{- $cnpgClusterName := (include "tc.v1.common.lib.cnpg.clusterName" (dict "objectData" $objectData)) -}}
  {{- $backupName := printf "%v-backup-%v" $objectData.name $objectData.schedData.name -}}

  {{/* Metadata */}}
  {{- $objLabels := $objectData.labels | default dict -}}
  {{- $backupLabels := $objectData.backups.labels | default dict -}}
  {{- $backupLabels = mustMerge $backupLabels $objLabels -}}

  {{- $objAnnotations := $objectData.annotations | default dict -}}
  {{- $backupAnnotations := $objectData.backups.annotations | default dict -}}
  {{- $backupAnnotations = mustMerge $backupAnnotations $objAnnotations }}
---
apiVersion: postgresql.cnpg.io/v1
kind: ScheduledBackup
metadata:
  name: {{ $backupName }}
  namespace: {{ include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $rootCtx "objectData" $objectData "caller" "CNPG Pooler") }}
  labels:
    cnpg.io/cluster: {{ $cnpgClusterName }}
  {{- $labels := (mustMerge $backupLabels (include "tc.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
    {{- . | nindent 4 }}
  {{- end -}}
  {{- $annotations := (mustMerge $backupAnnotations (include "tc.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
spec:
  cluster:
    name: {{ $cnpgClusterName }}
  schedule: {{ $objectData.schedData.schedule }}
  backupOwnerReference: {{ $objectData.schedData.backupOwnerReference }}
{{- end -}}
