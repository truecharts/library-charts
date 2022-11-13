{{/*
This template serves as a blueprint for all cnpg objects that are created
within the common library.
*/}}
{{- define "tc.common.dependencies.cnpg.main" -}}

{{- $cnpgName := include "tc.common.names.fullname" . -}}
{{- $cnpgName = printf "%v-%v" $cnpgName "cnpg" -}}
---
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: {{ $cnpgName }}
  {{- with (merge (.Values.cnpg.labels | default dict) (include "tc.common.labels" $ | fromYaml)) }}
  labels: {{- tpl ( toYaml . ) $ | nindent 4 }}
  {{- end }}
  annotations:
  {{- with (merge (.Values.cnpg.annotations | default dict) (include "tc.common.annotations" $ | fromYaml)) }}
    {{- tpl ( toYaml . ) $ | nindent 4 }}
  {{- end }}
spec:
  instances: {{ .Values.cnpg.instances | default 2  }}

  bootstrap:
    initdb:
      database: {{ .Values.cnpg.database | default "app" }}
      owner: {{ .Values.cnpg.user | default "app" }}


  # Example of rolling update strategy:
  # - unsupervised: automated update of the primary once all
  #                 replicas have been upgraded (default)
  # - supervised: requires manual supervision to perform
  #               the switchover of the primary
  primaryUpdateStrategy: {{ .Values.cnpg.primaryUpdateStrategy | default "unsupervised" }}

  storage:
    pvcTemplate:
      {{ include "tc.common.storage.storageClassName" ( dict "persistence" .Values.cnpg.storage.pvcTemplate "global" $) }}
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: {{ .Values.cnpg.storage.size | default "256Gi" | quote }}
  walStorage:
    pvcTemplate:
      {{ include "tc.common.storage.storageClassName" ( dict "persistence" .Values.cnpg.storage.pvcTemplate "global" $) }}
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: {{ .Values.cnpg.storage.walsize | default "256Gi" | quote }}

  monitoring:
    enablePodMonitor: {{ .Values.cnpg.monitoring.enablePodMonitor | default true }}

  NodeMaintenanceWindow:
    reusePVC: true
---
apiVersion: postgresql.cnpg.io/v1
kind: Pooler
metadata:
  name: pooler-{{ $cnpgName }}-rw
spec:
  cluster:
    name: {{ $cnpgName }}

  instances: {{ .Values.cnpg.instances | default 2 }}
  type: rw
  pgbouncer:
    poolMode: session
    parameters:
      max_client_conn: "1000"
      default_pool_size: "10"
{{- if ( .Values.cnpg.monitoring.enablePodMonitor | default true ) }}
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
{{- if ( .Values.cnpg.acceptRO | default true ) }}
---
apiVersion: postgresql.cnpg.io/v1
kind: Pooler
metadata:
  name: pooler-{{ $cnpgName }}-ro
spec:
  cluster:
    name: {{ $cnpgName }}

  instances: {{ .Values.cnpg.instances | default 2 }}
  type: ro
  pgbouncer:
    poolMode: session
    parameters:
      max_client_conn: "1000"
      default_pool_size: "10"
{{- if ( .Values.cnpg.monitoring.enablePodMonitor | default true ) }}
---
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: {{ $cnpgName }}-ro
spec:
  selector:
    matchLabels:
      cnpg.io/poolerName: {{ $cnpgName }}-ro
  podMetricsEndpoints:
  - port: metrics
{{- end }}
---
apiVersion: v1
kind: Secret
metadata:
  labels:
    {{- include "tc.common.labels" . | nindent 4 }}
  name: cnpgcreds
{{- $dbprevious := lookup "v1" "Secret" .Release.Namespace "cnpgcreds" }}
{{- $dbPass := "" }}
{{- $pgPass := "" }}
data:
{{- if $dbprevious }}
  {{- $dbPass = ( index $dbprevious.data "postgresql-password" ) | b64dec  }}
  {{- $pgPass = ( index $dbprevious.data "postgresql-postgres-password" ) | b64dec  }}
  postgresql-password: {{ ( index $dbprevious.data "postgresql-password" ) }}
  postgresql-postgres-password: {{ ( index $dbprevious.data "postgresql-postgres-password" ) }}
{{- else }}
  {{- $dbPass = .values.cnpg.password | default ( randAlphaNum 62 ) }}
  {{- $pgPass = .values.cnpg.superUserPassword | default ( randAlphaNum 62 ) }}
  postgresql-password: {{ $dbPass | b64enc | quote }}
  postgresql-postgres-password: {{ $pgPass | b64enc | quote }}
{{- end }}
  {{- $std := ( ( printf "postgresql://%v:%v@%v-postgresql:5432/%v" .Values.postgresql.postgresqlUsername $dbPass .Release.Name .Values.postgresql.postgresqlDatabase  ) | b64enc | quote ) }}
  {{- $nossl := ( ( printf "postgresql://%v:%v@%v-postgresql:5432/%v?sslmode=disable" .Values.postgresql.postgresqlUsername $dbPass .Release.Name .Values.postgresql.postgresqlDatabase  ) | b64enc | quote ) }}
  {{- $porthost := ( ( printf "%v-%v:5432" .Release.Name "postgresql" ) | b64enc | quote ) }}
  {{- $host := ( ( printf "%v-%v" .Release.Name "postgresql" ) | b64enc | quote ) }}
  {{- $jdbc := ( ( printf "jdbc:postgresql://%v-postgresql:5432/%v" .Release.Name .Values.postgresql.postgresqlDatabase  ) | b64enc | quote ) }}

  std: {{ $std }}
  nossl: {{ $nossl }}
  porthost: {{  }}
  host: {{ $porthost }}
  jdbc: {{ $jdbc }}
type: Opaque
{{- $_ := set .Values.postgresql "postgresqlPassword" ( $dbPass | quote ) }}
{{- $_ := set .Values.postgresql "postgrespassword" ( $pgPass | quote ) }}
{{- $_ := set .Values.postgresql.url "std" $std }}
{{- $_ := set .Values.postgresql.url "nossl" $nossl }}
{{- $_ := set .Values.postgresql.url "porthost"  }}
{{- $_ := set .Values.postgresql.url "host" $porthost }}
{{- $_ := set .Values.postgresql.url "jdbc" $jdbc }}
---
apiVersion: v1
data:
  username: postgres
  password: {{ $pgPass }}
kind: Secret
metadata:
  name: cnpg-superuser
type: kubernetes.io/basic-auth
---
apiVersion: v1
data:
  username: {{ .Values.cnpg.user }}
  password: {{ $dbPass }}
kind: Secret
metadata:
  name: cnpg-user
type: kubernetes.io/basic-auth

{{- end }}
{{- end }}
