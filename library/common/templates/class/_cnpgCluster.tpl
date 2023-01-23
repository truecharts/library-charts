{{- define "tc.v1.common.class.cnpg.cluster" -}}
  {{- $fullName := include "ix.v1.common.names.fullname" . -}}
  {{- $cnpgClusterName := $fullName -}}
  {{- $values := .Values.cnpg -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.cnpg -}}
      {{- $values = . -}}
    {{- end -}}
  {{- end -}}
  {{- $cnpgClusterLabels := $values.labels -}}
  {{- $cnpgClusterAnnotations := $values.annotations -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $cnpgClusterName = printf "%v-%v" $cnpgClusterName $values.nameOverride -}}
  {{- end }}
---
apiVersion: {{ include "tc.v1.common.capabilities.cnpg.cluster.apiVersion" $ }}
kind:
metadata:
  name: {{ $cnpgClusterName }}
  {{- $labels := (mustMerge ($cnpgClusterLabels | default dict) (include "ix.v1.common.labels" $ | fromYaml)) -}}
  {{- with (include "ix.v1.common.util.labels.render" (dict "root" $ "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end }}
  {{- $annotations := (mustMerge ($cnpgClusterAnnotations | default dict) (include "ix.v1.common.annotations" $ | fromYaml)) -}}
  {{- with (include "ix.v1.common.util.annotations.render" (dict "root" $ "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
spec:
  instances: {{ $values.instances | default 2  }}

  bootstrap:
    initdb:
      database: {{ $values.database | default "app" }}
      owner: {{ $values.user | default "app" }}

  primaryUpdateStrategy: {{ $values.primaryUpdateStrategy | default "unsupervised" }}

  storage:
    pvcTemplate:
      {{- with (include "ix.v1.common.storage.storageClassName" (dict "persistence" $values "root" $)) | trim }}
      storageClassName: {{ . }}
      {{- end }}
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: {{ tpl ($values.storage.walsize | default $.Values.global.defaults.VCTSize) $ | quote }}

  walStorage:
    pvcTemplate:
      {{- with (include "ix.v1.common.storage.storageClassName" (dict "persistence" $values "root" $)) | trim }}
      storageClassName: {{ . }}
      {{- end }}
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: {{ tpl ($values.storage.walsize | default $.Values.global.defaults.VCTSize) $ | quote }}

  monitoring:
    enablePodMonitor: {{ $values.monitoring.enablePodMonitor | default true }}

  nodeMaintenanceWindow:
    inProgress: false
    reusePVC: on


{{- end -}}
