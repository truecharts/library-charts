{{/* Configmap Class */}}
{{/* Call this template:
{{ include "tc.v1.common.class.storageclass" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the chart.
objectData:
  name: The name of the storageclass.
  labels: The labels of the storageclass.
  annotations: The annotations of the storageclass.
*/}}

{{- define "tc.v1.common.class.storageclass" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $allowVolExpand := true -}}
  {{- if not (kindIs "invalid" $objectData.allowVolumeExpansion) -}}
    {{- $allowVolExpand = $objectData.allowVolumeExpansion -}}
  {{- end }}
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: {{ $objectData.name }}
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
provisioner: {{ $objectData.provisioner }}
{{- with $objectData.parameters }}
parameters:
  {{- tpl (toYaml .) $rootCtx | nindent 2 }}
{{- end }}
reclaimPolicy: {{ $objectData.reclaimPolicy | default "Retain" }}
allowVolumeExpansion: {{ $allowVolExpand }}
{{- with $objectData.mountOptions }}
mountOptions:
  {{- tpl (toYaml .) $rootCtx | nindent 2 }}
{{- end }}
volumeBindingMode: {{ $objectData.volumeBindingMode | default "Immediate" }}
{{- end -}}
