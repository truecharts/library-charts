{{/* volumesnapshotclass Class */}}
{{/* Call this template:
{{ include "tc.v1.common.class.volumesnapshotclass" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the chart.
objectData:
  name: The name of the volumesnapshotclass.
  labels: The labels of the volumesnapshotclass.
  annotations: The annotations of the volumesnapshotclass.
*/}}

{{- define "tc.v1.common.class.volumesnapshotclass" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}
  {{- $isDefault := dict -}}
  {{- with $objectdata.isDefault -}}
    {{- $isDefault := dict "snapshot.storage.kubernetes.io/is-default-class" . -}}
  {{- end -}}
---
apiVersion: v1
kind: volumesnapshotclass
metadata:
  name: {{ $objectData.name }}
  {{- $labels := (mustMerge ($objectData.labels | default dict) (include "tc.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- $annotations := (mustMerge ($objectData.annotations | default dict) $isDefault (include "tc.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
data:
  driver: {{ $objectdata.driver }}
  deletionPolicy: {{ $objectdata.deletionPolicy | default "Retain" }}
  {{- with $objectdata.parameters -}}
  parameters: {}
  {{- tpl (toYaml .) $rootCtx | nindent 4 }}
  {{- end -}}
{{- end -}}
