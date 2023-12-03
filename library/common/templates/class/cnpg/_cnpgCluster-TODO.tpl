{{- define "tc.v1.common.class.cnpg.cluster" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $fullname := include "tc.v1.common.lib.chart.names.fullname" $rootCtx -}}
  {{- include "tc.v1.common.lib.chart.names.validation" (dict "name" $objectData.clusterName "length" 253) -}}
  {{- include "tc.v1.common.lib.metadata.validation" (dict "objectData" $objectData "caller" "CNPG Cluster") -}}

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

  {{/* General */}}
  {{- $mode := "standalone" -}}
  {{- with $objectData.mode -}}
    {{- $mode = . -}}
  {{- end -}}

  {{/* Monitoring */}}
  {{- $enableMonitoring := false -}}
  {{- with $objectData.monitoring -}}
    {{- if (kindIs "bool" .enablePodMonitor) -}}
      {{- $enableMonitoring = .enablePodMonitor -}}
    {{- end -}}
  {{- end -}}

  {{- $customQueries := list -}}
  {{- with $objectData.cluster.monitoring.customQueries -}}
    {{- $customQueries = . -}}
  {{- end -}}

  {{/* Superuser */}}
  {{- $enableSuperUser := true -}}
  {{- if (kindIs "bool" $objectData.cluster.enableSuperuserAccess) -}}
    {{- $enableSuperUser = $objectData.cluster.enableSuperuserAccess -}}
  {{- end -}}

  {{/* Node Maintenance Window */}}
  {{- $inProgress := false -}}
  {{- $reusePVC := true -}}
  {{- if or $rootCtx.Values.global.ixChartContext $objectData.cluster.singleNode -}}
    {{- $inProgress = true -}}
    {{- $reusePVC = true -}}
  {{- end -}}

  {{- with $objectData.cluster.nodeMaintenanceWindow -}}
    {{- if (kindIs "bool" .inProgress) }}
      {{ $inProgress = .inProgress }}
    {{- end -}}
    {{- if (kindIs "bool" .reusePVC) }}
      {{ $reusePVC = .reusePVC }}
    {{- end -}}
  {{- end -}}

  {{/* Preload Libraries */}}
  {{- $preloadLibraries := list -}}
  {{- if (kindIs "slice" $objectData.cluster.preloadLibraries) -}}
    {{- $preloadLibraries = $objectData.cluster.preloadLibraries -}}
  {{- end -}}
  {{- if eq $objectData.type "timescaledb" -}}
    {{- $preloadLibraries = mustAppend $preloadLibraries "timescaledb" -}}
  {{- end -}}

  {{/* Storage */}}
  {{- $size := $rootCtx.Values.fallbackDefaults.vctSize -}}
  {{- with $objectData.cluster.storage.size -}}
    {{- $size = . -}}
  {{- end -}}

  {{- $walSize := $rootCtx.Values.fallbackDefaults.vctSize -}}
  {{- with $objectData.cluster.walStorage.size -}}
    {{- $walSize = . -}}
  {{- end }}
---
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: {{ $objectData.clusterName }}
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
  enableSuperuserAccess: {{ $enableSuperUser }}
  primaryUpdateStrategy: {{ $objectData.cluster.primaryUpdateStrategy | default "unsupervised" }}
  primaryUpdateMethod: {{ $objectData.cluster.primaryUpdateMethod | default "switchover" }}
  logLevel: {{ $objectData.cluster.logLevel | default "info" }}
  {{- range $k, $v := $objectData.cluster.certificates }}
  certificates:
    {{ $k }}: {{ $v | quote }}
  {{- end }}
  storage:
    pvcTemplate:
      {{- include "tc.v1.common.lib.storage.pvc.spec" (dict "rootCtx" $rootCtx "objectData" $objectData.storage) | trim | nindent 6 }}
  walStorage:
    pvcTemplate:
      {{- include "tc.v1.common.lib.storage.pvc.spec" (dict "rootCtx" $rootCtx "objectData" $objectData.walStorage) | trim | nindent 6 }}
  monitoring:
    enablePodMonitor: {{ $enableMonitoring }}
    {{- if $customQueries }}
    customQueriesConfigMap:
      {{- range $q := $customQueries }}
        {{- $name := $q.name -}}

        {{- $expandName := (include "tc.v1.common.lib.util.expandName" (dict
                        "rootCtx" $rootCtx "objectData" $q
                        "name" $q.name "caller" "CNPG Cluster"
                        "key" "customQueries")) -}}

        {{- if eq $expandName "true" -}}
          {{- $name = (printf "%s-%s" $fullname $q.name) -}}
        {{- end }}
      - name: {{ $name }}
        key: {{ $q.key }}
      {{- end -}}
    {{- end }}
  nodeMaintenanceWindow:
    inProgress: {{ $inProgress }}
    reusePVC: {{ $reusePVC }}
  {{- with (include "tc.v1.common.lib.container.resources" (dict "rootCtx" $rootCtx "objectData" $objectData.cluster) | trim) }}
  resources:
    {{- . | nindent 4 }}
  {{- end }}
  postgresql:
    {{- with $preloadLibraries }}
    shared_preload_libraries:
      {{- range $lib := (. | uniq) }}
      - {{ $lib | quote }}
      {{- end -}}
    {{- end -}}
    {{- with $objectData.cluster.postgresql }}
    parameters:
    {{- range $k, $v := . }}
      {{ $k }}: {{ tpl $v $rootCtx | quote }}
    {{- end -}}
  {{- end -}}
{{- end -}}
