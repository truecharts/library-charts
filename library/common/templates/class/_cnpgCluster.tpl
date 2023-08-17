{{- define "tc.v1.common.class.cnpg.cluster" -}}
  {{- $values := .Values.cnpg -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.cnpg -}}
      {{- $values = . -}}
    {{- end -}}
  {{- end -}}
  {{- $cnpgClusterName := $values.name -}}
  {{- $cnpgLabels := $values.labels -}}
  {{- $cnpgAnnotations := $values.annotations -}}
  {{- $cnpgClusterLabels := $values.cluster.labels -}}
  {{- $cnpgClusterAnnotations := $values.cluster.annotations -}}
  {{- $hibernation := "off" -}}
  {{- if or $values.hibernate $.Values.global.stopAll -}}
    {{- $hibernation = "on" -}}
  {{- end }}
---
apiVersion: {{ include "tc.v1.common.capabilities.cnpg.cluster.apiVersion" $ }}
kind: Cluster
metadata:
  name: {{ $cnpgClusterName }}
  namespace: {{ $.Values.namespace | default $.Values.global.namespace | default $.Release.Namespace }}
  {{- $labels := (mustMerge ($cnpgClusterLabels | default dict) ($cnpgLabels | default dict) (include "tc.v1.common.lib.metadata.allLabels" $ | fromYaml)) }}
  labels:
    cnpg.io/reload: "on"
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $ "labels" $labels) | trim) }}
    {{- . | nindent 4 }}
  {{- end }}
  {{- $annotations := (mustMerge ($cnpgClusterAnnotations | default dict) ($cnpgAnnotations | default dict) (include "tc.v1.common.lib.metadata.allAnnotations" $ | fromYaml)) }}
  annotations:
    rollme: {{ randAlphaNum 5 | quote }}
    cnpg.io/hibernation: {{ $hibernation | quote }}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $ "annotations" $annotations) | trim) }}
    {{- . | nindent 4 }}
  {{- end }}
spec:
  instances: {{ $values.cluster.instances | default 2 }}

  bootstrap:
    initdb:
      database: {{ $values.database | default "app" }}
      owner: {{ $values.user | default "app" }}
      secret:
        name: {{ $cnpgClusterName }}-user

  enableSuperuserAccess: {{ $values.cluster.enableSuperuserAccess | default "true" }}

  primaryUpdateStrategy: {{ $values.cluster.primaryUpdateStrategy | default "unsupervised" }}
  primaryUpdateMethod: {{ $values.cluster.primaryUpdateMethod | default "switchover" }}

  logLevel: {{ $values.cluster.logLevel }}

  {{- with $values.cluster.certificates }}
  certificates:
    {{- toYaml . | nindent 4 }}
  {{ end }}

  storage:
    {{- with (include "tc.v1.common.lib.storage.storageClassName" ( dict "rootCtx" $ "objectData" $values.cluster.storage )) | trim }}
    storageClass: {{ . }}
    {{- end }}
    size: {{ tpl ($values.cluster.storage.size | default $.Values.fallbackDefaults.vctSize) $ | quote }}

  walStorage:
    {{- with (include "tc.v1.common.lib.storage.storageClassName" ( dict "rootCtx" $ "objectData" $values.cluster.storage )) | trim }}
    storageClass: {{ . }}
    {{- end }}
    size: {{ tpl ($values.cluster.storage.walsize | default $.Values.fallbackDefaults.vctSize) $ | quote }}

  monitoring:
    enablePodMonitor: {{ $values.monitoring.enablePodMonitor | default true }}
    {{- if not (empty $values.cluster.monitoring.customQueries) }}
    customQueriesConfigMap:
      - name: {{ include "cluster.fullname" . }}-monitoring
        key: custom-queries
    {{- end }}

  {{- if or $values.cluster.nodeMaintenanceWindow $values.cluster.singleNode $rootCtx.Values.global.ixChartContext -}}
  nodeMaintenanceWindow:
    {{- if or $rootCtx.Values.global.ixChartContext $values.cluster.singleNode -}}
    {{- if not  $values.cluster.nodeMaintenanceWindow.inProgress -}}
    inProgress: true
    {{- end -}}
    {{- if not  $values.cluster.nodeMaintenanceWindow.reusePVC -}}
    reusePVC: true
    {{- end -}}
    {{- end -}}
    {{- with $values.cluster.nodeMaintenanceWindow }}
      {{- toYaml . | nindent 6 }}
    {{ end }}
  {{- end -}}

  {{- with (include "tc.v1.common.lib.container.resources" (dict "rootCtx" $ "objectData" $values.cluster) | trim) }}
  resources:
    {{- . | nindent 4 }}
  {{- end }}

  postgresql:
    shared_preload_libraries:
      {{- if eq $values.type "timescaledb" }}
      - timescaledb
      {{- end }}
    {{- with $values.cluster.postgresql }}
    parameters:
      {{- toYaml . | nindent 6 }}
    {{ end }}

{{- end -}}
