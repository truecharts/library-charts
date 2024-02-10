{{/* schedule Class */}}
{{/* Call this template:
{{ include "tc.v1.common.class.velero.schedule" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the chart.
objectData:
  name: The name of the schedule.
  labels: The labels of the schedule.
  annotations: The annotations of the schedule.
  namespace: The namespace of the schedule. (Optional)
*/}}

{{- define "tc.v1.common.class.velero.schedule" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}
  {{- $namespace := (include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $rootCtx "objectData" $objectData "caller" "Velero Schedule")) -}}

  {{/* Get existing BSLs */}}
  {{- $lookupBSL := (lookup "velero.io/v1" "BackupStorageLocation" "" "") -}}
  {{/* TODO: Why we only keep one namespace of the found BSLs?
    In this case we can just get the `| first` item
  */}}
  {{- range $bsl := $lookupBSL.items -}}
    {{- $namespace = $bsl.metadata.namespace -}}
  {{- end }}
---
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: {{ $objectData.name }}
  namespace: {{ $namespace }}
  {{- $labels := (mustMerge ($objectData.labels | default dict) (include "tc.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- $annotations := (mustMerge ($objectData.annotations | default dict) (include "tc.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
spec:
  schedule: {{ $objectData.schedule | quote }}
  {{- if (kindIs "bool" $objectData.useOwnerReferencesInBackup) }}
  useOwnerReferencesInBackup: {{ $objectData.useOwnerReferencesInBackup }}
  {{- end }}
  template:
  {{- if not $objectData.template }}
    includeClusterResources: true
    includedNamespaces:
      - {{ include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $rootCtx "objectData" $objectData "caller" "Velero Schedule") }}
    orLabelSelectors:
      - matchLabels:
          app.kubernetes.io/instance: {{ $rootCtx.Release.Name }}
      - matchLabels:
          release: {{ $rootCtx.Release.Name }}
      - matchLabels:
          owner: helm
          name: {{ $rootCtx.Release.Name }}
  {{- end -}}
  {{- with $objectData.template }}
    {{/*
      TODO: This toYaml should **not** be here if any of the checks
      below renders when a key is present. Currently, checks below
      only render when a key is not present, which is mostly safe
      to use along with the toYaml.
     */}}
    {{- toYaml . | nindent 4 }}
    {{- if not (hasKey .  "includeClusterResources") }}
    includeClusterResources: true
    {{- end -}}
    {{- if not .orLabelSelectors }}
    orLabelSelectors:
      - matchLabels:
          app.kubernetes.io/instance: {{ $rootCtx.Release.Name }}
      - matchLabels:
          release: {{ $rootCtx.Release.Name }}
      - matchLabels:
          owner: helm
          name: {{ $rootCtx.Release.Name }}
    {{- end -}}
    {{- if not .includedNamespaces }}
    includedNamespaces:
      - {{ include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $rootCtx "objectData" $objectData "caller" "Velero Schedule") }}
    {{- end -}}
  {{- end -}}
{{- end -}}
