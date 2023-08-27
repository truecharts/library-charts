{{- define "tc.v1.common.class.cnpg.scheduledbackup" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $cnpgClusterName := $objectData.name -}}

  {{- if and $objectData.version (ne $objectData.version "legacy") -}}
    {{- $cnpgClusterName = printf "%v-%v" $objectData.name $objectData.version -}}
  {{- end -}}

  {{- if $objectData.recValue -}}
    {{- $cnpgClusterName = printf "%v-%v" $cnpgClusterName $objectData.recValue -}}
  {{- end -}}


  {{- $cnpgBackupName := $objectData.backupName -}}
  {{- $cnpgLabels := $objectData.labels -}}
  {{- $cnpgAnnotations := $objectData.annotations -}}
  {{- $cnpgBackupLabels := ($objectData.backups | default dict).labels -}}
  {{- $cnpgBackupAnnotations := ($objectData.backups | default dict).annotations -}}
---
apiVersion: {{ include "tc.v1.common.capabilities.cnpg.ScheduledBackup.apiVersion" $ }}
kind: ScheduledBackup
metadata:
  name: {{ printf "%v-backup-%v" $objectData.name $cnpgBackupName }}
  namespace: {{ include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $rootCtx "objectData" $objectData "caller" "CNPG Pooler") }}
  labels:
    cnpg.io/cluster: {{ $cnpgClusterName }}
  {{- $labels := (mustMerge ($cnpgBackupLabels | default dict) ($cnpgLabels | default dict) (include "tc.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
    {{- . | nindent 4 }}
  {{- end }}
  {{- $annotations := (mustMerge ($cnpgBackupAnnotations | default dict) ($cnpgAnnotations | default dict) (include "tc.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
spec:
  cluster:
    name: {{ $cnpgClusterName }}
  schedule: {{ $objectData.backups.schedule }}
  backupOwnerReference: {{ $objectData.backups.backupOwnerReference }}
{{- end -}}
