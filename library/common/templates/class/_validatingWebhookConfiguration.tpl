{{/* validatingwebhookconfiguration Class */}}
{{/* Call this template:
{{ include "tc.v1.common.class.validatingwebhookconfiguration" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the chart.
objectData:
  name: The name of the validatingwebhookconfiguration.
  labels: The labels of the validatingwebhookconfiguration.
  annotations: The annotations of the validatingwebhookconfiguration.
  data: The data of the validatingwebhookconfiguration.
  namespace: The namespace of the validatingwebhookconfiguration. (Optional)
*/}}

{{- define "tc.v1.common.class.validatingwebhookconfiguration" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
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
  {{- end -}}
  {{- with $objectData.namespace }}
  namespace: {{ tpl . $rootCtx }}
  {{- end }}
webhooks:
  {{- tpl (toYaml $objectData.webhooks) $rootCtx | nindent 2 }}
  {{/* This comment is here to add a new line */}}
{{- end -}}
