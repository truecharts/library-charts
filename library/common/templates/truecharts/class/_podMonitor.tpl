{{- define "tc.v1.common.class.podmonitor" -}}
  {{- $fullName := include "tc.v1.common.lib.chart.names.fullname" . -}}
  {{- $podmonitorName := $fullName -}}
  {{- $values := .Values.podmonitor -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.metrics -}}
      {{- $values = . -}}
    {{- end -}}
  {{- end -}}
  {{- $podmonitorLabels := $values.labels -}}
  {{- $podmonitorAnnotations := $values.annotations -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $podmonitorName = printf "%v-%v" $podmonitorName $values.nameOverride -}}
  {{- end }}
---
apiVersion: {{ include "tc.v1.common.capabilities.podmonitor.apiVersion" $ }}
kind: PodMonitor
metadata:
  name: {{ $podmonitorName }}
  {{- $labels := (mustMerge ($podmonitorLabels | default dict) (include "tc.v1.common.lib.metadata.allLabels" $ | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $ "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end }}
  {{- $annotations := (mustMerge ($podmonitorAnnotations | default dict) (include "tc.v1.common.lib.metadata.allAnnotations" $ | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $ "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
spec:
  jobLabel: app.kubernetes.io/name
  selector:
    {{- if $values.selector }}
    {{- tpl (toYaml $values.selector) $ | nindent 4 }}
    {{- else }}
    matchLabels:
      {{ $primaryPodName := (include "tc.v1.common.lib.util.workload.primary" (dict "workload" .Values.workloads "root" $)) }}
      {{ include "tc.v1.common.lib.metadata.selectorLabels" (dict "rootCtx" $ "objectType" "pod" "objectName" $primaryPodName) }}
    {{- end }}
  podMetricsEndpoints:
    {{- tpl (toYaml $values.endpoints) $ | nindent 4 }}
{{- end -}}
