{{- define "tc.v1.common.class.cnpg.cluster" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{/* Naming */}}
  {{- $cnpgClusterName := (include "tc.v1.common.lib.cnpg.clusterName" (dict "objectData" $objectData)) -}}

  {{/* Metadata */}}
  {{- $objLabels := $objectData.labels | default dict -}}
  {{- $clusterLabels := $objectData.cluster.labels | default dict -}}
  {{- $clusterLabels = mustMerge $clusterLabels $objLabels -}}

  {{- $objAnnotations := $objectData.annotations | default dict -}}
  {{- $clusterAnnotations := $objectData.cluster.annotations | default dict -}}
  {{- $clusterAnnotations = mustMerge $clusterAnnotations $objAnnotations -}}

  {{/* Stop All */}}
  {{- $hibernation := "off" -}}
  {{- $instances := $objectData.cluster.instances | default 2 -}}
  {{- if or $objectData.hibernate (include "tc.v1.common.lib.util.stopAll" $rootCtx) -}}
    {{- $hibernation = "on" -}}
    {{- $instances = 0 -}}
  {{- end -}}

  {{- $monitoring := false -}}
  {{- with $objectData.monitoring -}}
    {{- if not (kindIs "invalid" .enablePodMonitor) -}}
      {{- $monitoring = .enablePodMonitor -}}
    {{- end -}}
  {{- end -}}

  {{- $size := $rootCtx.Values.fallbackDefaults.vctSize -}}
  {{- with $objectData.cluster.storage.size -}}
    {{- $size := . -}}
  {{- end -}}

  {{- $walSize := $rootCtx.Values.fallbackDefaults.vctSize -}}
  {{- with $objectData.cluster.walStorage.size -}}
    {{- $walSize := . -}}
  {{- end -}}

  {{- $customQueries := dict -}}
  {{- with $objectData.cluster.monitoring.customQueries -}}
    {{- $customQueries := . -}}
  {{- end }}
---
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: {{ $cnpgClusterName }}
  namespace: {{ include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $rootCtx "objectData" $objectData "caller" "CNPG Cluster") }}
  labels:
    cnpg.io/reload: "on"
  {{- $labels := (mustMerge $clusterLabels (include "tc.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
    {{- . | nindent 4 }}
  {{- end }}
  annotations:
    rollme: {{ randAlphaNum 5 | quote }}
    cnpg.io/hibernation: {{ $hibernation | quote }}
  {{- $annotations := (mustMerge $clusterAnnotations (include "tc.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
    {{- . | nindent 4 }}
  {{- end }}
spec:
  instances: {{ $instances }}
  bootstrap:
  {{- if eq $objectData.mode "standalone" -}}
    {{- include "tc.v1.common.lib.cnpg.cluster.bootstrap.standalone" (dict "objectData" $objectData) | nindent 4 -}}
  {{- else if eq $objectData.mode "recovery" -}}
    {{- include "tc.v1.common.lib.cnpg.cluster.bootstrap.recovery" (dict "objectData" $objectData) | nindent 4 -}}
    {{- include "tc.v1.common.lib.cnpg.cluster.bootstrap.recovery.externalCluster" (dict "objectData" $objectData) | nindent 2 -}}
  {{- end -}}
{{- if $objectData.backups.enabled }}
  {{- include "tc.v1.common.lib.cnpg.cluster.backup" (dict $objectData) | nindent 2 -}}
{{- end }}
{{/* TODO: Cleanup-Checkpoint */}}
  enableSuperuserAccess: {{ $objectData.cluster.enableSuperuserAccess | default "true" }}
  primaryUpdateStrategy: {{ $objectData.cluster.primaryUpdateStrategy | default "unsupervised" }}
  primaryUpdateMethod: {{ $objectData.cluster.primaryUpdateMethod | default "switchover" }}
  logLevel: {{ $objectData.cluster.logLevel }}
  {{- with $objectData.cluster.certificates }}
  certificates:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  storage:
    {{- with (include "tc.v1.common.lib.storage.storageClassName" (dict "rootCtx" $rootCtx "objectData" $objectData.cluster.storage)) | trim }}
    storageClass: {{ . }}
    {{- end }}
    size: {{ tpl $size $rootCtx | quote }}
  walStorage:
    {{- with (include "tc.v1.common.lib.storage.storageClassName" (dict "rootCtx" $rootCtx "objectData" $objectData.cluster.walStorage)) | trim }}
    storageClass: {{ . }}
    {{- end }}
    size: {{ tpl $walSize $rootCtx | quote }}
  monitoring:
    enablePodMonitor: {{ $monitoring }}
    {{- if $customQueries }}
    customQueriesConfigMap:
      - name: {{ printf "%s-monitoring" (include "cluster.fullname" .) }}
        key: custom-queries
    {{- end }}
  nodeMaintenanceWindow:
  {{- if $objectData.cluster.nodeMaintenanceWindow -}}
    {{- toYaml $objectData.cluster.nodeMaintenanceWindow | nindent 6 -}}
  {{- else -}}
    {{- if or $rootCtx.Values.global.ixChartContext $objectData.cluster.singleNode }}
    inProgress: true
    reusePVC: true
    {{- end -}}
  {{- end -}}
  {{- with (include "tc.v1.common.lib.container.resources" (dict "rootCtx" $rootCtx "objectData" $objectData.cluster) | trim) }}
  resources:
    {{- . | nindent 4 }}
  {{- end }}
  postgresql:
    shared_preload_libraries:
      {{- if eq $objectData.type "timescaledb" }}
      - timescaledb
      {{- end -}}
    {{- with $objectData.cluster.postgresql }}
    parameters:
      {{- toYaml . | nindent 6 }}
    {{- end -}}
{{- end -}}
