{{- define "tc.v1.common.class.cnpg.cluster" -}}
  {{- $values := .Values.cnpg -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.cnpg -}}
      {{- $values = . -}}
    {{- end -}}
  {{- end -}}
  {{- $cnpgClusterName := $values.name -}}
  {{- $cnpgClusterLabels := $values.labels -}}
  {{- $cnpgClusterAnnotations := $values.annotations }}

---
apiVersion: {{ include "tc.v1.common.capabilities.cnpg.cluster.apiVersion" $ }}
kind: Cluster
metadata:
  name: {{ $cnpgClusterName }}
  {{- $labels := (mustMerge ($cnpgClusterLabels | default dict) (include "tc.v1.common.lib.metadata.allLabels" $ | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $ "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end }}
  {{- $annotations := (mustMerge ($cnpgClusterAnnotations | default dict) (include "tc.v1.common.lib.metadata.allAnnotations" $ | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $ "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
spec:
  instances: {{ $values.instances | default 2  }}

  {{- $basename := include "tc.v1.common.lib.chart.names.fullname" $ -}}
  {{- $fetchname := printf "%s-dbcreds" $basename -}}
  {{- $olddbprevious1 := lookup "v1" "Secret" .Release.Namespace $fetchname }}
  {{- $olddbprevious2 := lookup "v1" "Secret" .Release.Namespace "dbcreds" }}

  bootstrap:
  {{- if and $.Values.postgresql.enabled ( or $olddbprevious1 $olddbprevious2 ) $.Release.IsUpgrade }}
    pg_basebackup:
      source: old-db
  {{- else }}
    initdb:
  {{- end }}
      database: {{ $values.database | default "app" }}
      owner: {{ $values.user | default "app" }}
      secret:
        name: {{ $cnpgClusterName }}-user

  primaryUpdateStrategy: {{ $values.primaryUpdateStrategy | default "unsupervised" }}

  storage:
    pvcTemplate:
      {{- with (include "tc.v1.common.lib.storage.storageClassName" (dict "persistence" $values.storage "root" . )) | trim }}
      storageClassName: {{ . }}
      {{- end }}
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: {{ tpl ($values.storage.walsize | default $.Values.fallbackDefaults.vctSize) $ | quote }}

  walStorage:
    pvcTemplate:
      {{- with (include "tc.v1.common.lib.storage.storageClassName" (dict "persistence" $values.storage "root" $ )) | trim }}
      storageClassName: {{ . }}
      {{- end }}
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: {{ tpl ($values.storage.walsize | default $.Values.fallbackDefaults.vctSize) $ | quote }}

  monitoring:
    enablePodMonitor: {{ $values.monitoring.enablePodMonitor | default true }}

  nodeMaintenanceWindow:
    inProgress: false
    reusePVC: on

  # externalClusters:
  # - name: old-db
  #   connectionParameters:
  #     host: somehost
  #     user: postgres
  #   password:
  #     name: somepass-superuser
  #     key: password

{{- end -}}
