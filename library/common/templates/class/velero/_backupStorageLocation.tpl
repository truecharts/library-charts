{{/* backupstoragelocation Class */}}
{{/* Call this template:
{{ include "tc.v1.common.class.velero.backupstoragelocation" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the chart.
objectData:
  name: The name of the backupstoragelocation.
  labels: The labels of the backupstoragelocation.
  annotations: The annotations of the backupstoragelocation.
  namespace: The namespace of the backupstoragelocation. (Optional)
*/}}

{{- define "tc.v1.common.class.velero.backupstoragelocation" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}
---
apiVersion: velero.io/v1
kind: BackupStorageLocation
metadata:
  name: {{ $objectData.name }}
  namespace: {{ include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $rootCtx "objectData" $objectData "caller" "backupstoragelocation") }}
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
  {{- if not (empty $objectData.credential) }}
  credential:
    {{- with $objectData.credential.name }}
    name: {{ . }}
    {{- end }}
    {{- with $objectData.credential.key }}
    key: {{ . }}
    {{- end }}
  {{- end }}
  provider: {{ $objectData.provider }}
  accessMode: {{ $objectData.accessMode | default "ReadWrite" }}
  {{- with $objectData.default }}
  default: {{ . }}
  {{- end }}
  {{- with $objectData.validationFrequency }}
  validationFrequency: {{ . }}
  {{- end }}
  objectStorage:
    bucket: {{ $objectData.bucket | quote }}
    {{- with $objectData.prefix }}
    prefix: {{ . | quote }}
    {{- end }}
    {{- with $objectData.caCert }}
    caCert: {{ . }}
    {{- end }}
{{- with $objectData.config }}
  config:
{{- range $key, $value := . }}
{{- $key | nindent 4 }}: {{ $value | quote }}
{{- end }}
{{- end }}


{{- end -}}
