{{- define "tc.v1.common.class.cnpg.cluster" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $cnpgClusterName := $objectData.name -}}

  {{- if and $objectData.version (ne $objectData.version "legacy") -}}
    {{- $cnpgClusterName = printf "%v-%v" $objectData.name $objectData.version -}}
  {{- end -}}

  {{- if $objectData.recValue -}}
    {{- $cnpgClusterName = printf "%v-%v" $cnpgClusterName $objectData.recValue -}}
  {{- end -}}

  {{- $cnpgLabels := $objectData.labels | default dict -}}
  {{- $cnpgAnnotations := $objectData.annotations | default dict -}}
  {{- $cnpgClusterLabels := $objectData.cluster.labels | default dict -}}
  {{- $cnpgClusterAnnotations := $objectData.cluster.annotations | default dict -}}
  {{- $hibernation := "off" -}}
  {{- if or $objectData.hibernate (include "tc.v1.common.lib.util.stopAll" $) -}}
    {{- $hibernation = "on" -}}
  {{- end -}}

  {{- $monitoring := false -}}
  {{- with $objectData.monitoring -}}
    {{- if not (kindIs "invalid" .enablePodMonitor) -}}
      {{- $monitoring = .enablePodMonitor -}}
    {{- end -}}
  {{- end -}}

  {{- $initDB := $objectData.cluster.initdb -}}
  {{- $instances := $objectData.cluster.instances | default 2 -}}
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
  {{- end -}}

---
apiVersion: {{ include "tc.v1.common.capabilities.cnpg.cluster.apiVersion" $rootCtx }}
kind: Cluster
metadata:
  name: {{ $cnpgClusterName }}
  namespace: {{ include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $rootCtx "objectData" $objectData "caller" "CNPG Pooler") }}
  labels:
    cnpg.io/reload: "on"
  {{- $labels := (mustMerge $cnpgClusterLabels $cnpgLabels (include "tc.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
    {{- . | nindent 4 }}
  {{- end }}
  annotations:
    rollme: {{ randAlphaNum 5 | quote }}
    cnpg.io/hibernation: {{ $hibernation | quote }}
  {{- $annotations := (mustMerge $cnpgClusterAnnotations $cnpgAnnotations (include "tc.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
    {{- . | nindent 4 }}
  {{- end }}
spec:
  instances: {{ $instances }}
  bootstrap:
  {{- if eq $objectData.mode "standalone" }}
    initdb:
      database: {{ $objectData.database | default "app" }}
      owner: {{ $objectData.user | default "app" }}
      secret:
        name: {{ printf "%s-user" $cnpgClusterName }}
      {{- range $key, $val := (omit $initDB "postInitApplicationSQL" "database" "owner" "secret") }}
        {{- $key | nindent 6 }}: {{ $val | toYaml }}
      {{- end }}
      postInitApplicationSQL:
        {{- range $initDB.postInitApplicationSQL }}
          - {{ . }}
        {{- end -}}
        {{- if eq $objectData.type "postgis" }}
          - CREATE EXTENSION IF NOT EXISTS postgis;
          - CREATE EXTENSION IF NOT EXISTS postgis_topology;
          - CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
          - CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
        {{- else if eq $objectData.type "timescaledb" }}
          - CREATE EXTENSION IF NOT EXISTS timescaledb;
        {{- end }}
  {{- else if eq $objectData.mode "recovery" }}
    recovery:
      {{- with $objectData.recovery.pitrTarget.time }}
      recoveryTarget:
        targetTime: {{ . }}
      {{- end -}}
      {{- if eq $objectData.recovery.method "backup" }}
      backup:
        name: {{ $objectData.recovery.backupName }}
      {{- else if eq $objectData.recovery.method "object_store" }}
      source: objectStoreRecoveryCluster
      {{- end }}
      database: {{ $objectData.database | default "app" }}
      owner: {{ $objectData.user | default "app" }}
      secret:
        name: {{ printf "%s-user" $cnpgClusterName }}
  externalClusters:
    - name: objectStoreRecoveryCluster
      barmanObjectStore:
        serverName: {{ $objectData.recovery.serverName }}
        {{- $d1 := dict "chartFullname" $cnpgClusterName "scope" $objectData.recovery "secretSuffix" "-recovery" -}}
        {{- include "tc.v1.common.lib.cnpg.cluster.barmanObjectStoreConfig" $d1 | nindent 8 }}
  {{- end -}}
{{- if $objectData.backups.enabled }}
backup:
  target: "prefer-standby"
  retentionPolicy: {{ $objectData.backups.retentionPolicy }}
  barmanObjectStore:
    wal:
      compression: gzip
      encryption: AES256
    data:
      compression: gzip
      encryption: AES256
      jobs: {{ $objectData.backups.jobs | default 2 }}
    {{- $d2 := dict "chartFullname" $cnpgClusterName "scope" $objectData.backups -}}
    {{- include "tc.v1.common.lib.cnpg.cluster.barmanObjectStoreConfig" $d2 | nindent 4 -}}
{{- end }}
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
