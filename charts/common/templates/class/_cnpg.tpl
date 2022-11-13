{{/*
This template serves as a blueprint for all cnpg objects that are created
within the common library.
*/}}
{{- define "tc.common.class.cnpg" -}}
{{- $values := .Values.cnpg -}}
{{- if hasKey . "ObjectValues" -}}
  {{- with .ObjectValues.cnpg -}}
    {{- $values = . -}}
  {{- end -}}
{{ end -}}

{{- $cnpgName := include "tc.common.names.fullname" . -}}
{{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
  {{- $cnpgName = printf "%v-%v" $cnpgName $values.nameOverride -}}
{{ end -}}
---
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: {{ $cnpgName }}
  {{- with (merge ($values.labels | default dict) (include "tc.common.labels" $ | fromYaml)) }}
  labels: {{- tpl ( toYaml . ) $ | nindent 4 }}
  {{- end }}
  annotations:
  {{- with (merge ($values.annotations | default dict) (include "tc.common.annotations" $ | fromYaml)) }}
    {{- tpl ( toYaml . ) $ | nindent 4 }}
  {{- end }}
spec:
  instances: {{ $values.instances | default 2  }}

  bootstrap:
    initdb:
      database: {{ $values.database | default "app" }}
      owner: {{ $values.user | default "app" }}


  # Example of rolling update strategy:
  # - unsupervised: automated update of the primary once all
  #                 replicas have been upgraded (default)
  # - supervised: requires manual supervision to perform
  #               the switchover of the primary
  primaryUpdateStrategy: {{ $values.primaryUpdateStrategy | default "unsupervised" }}

  storage:
    {{ include "tc.common.storage.storageClass" ( dict "persistence" $values.storage "global" $ ) }}
    size: {{ $values.storage.size | default "256Gi" }}

  monitoring:
    enablePodMonitor: {{ $values.monitoring.enablePodMonitor | default true }}
---
apiVersion: postgresql.cnpg.io/v1
kind: Pooler
metadata:
  name: pooler-{{ $cnpgName }}-rw
spec:
  cluster:
    name: {{ $cnpgName }}

  instances: {{ $values.instances | default 2 }}
  type: rw
  pgbouncer:
    poolMode: session
    parameters:
      max_client_conn: "1000"
      default_pool_size: "10"
{{- if ( $values.monitoring.enablePodMonitor | default true ) }}
---
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: {{ $cnpgName }}-rw
spec:
  selector:
    matchLabels:
      cnpg.io/poolerName: {{ $cnpgName }}-rw
  podMetricsEndpoints:
  - port: metrics
{{- end }}
{{- end }}
