{{- define "tc.v1.common.class.servicemonitor" -}}
  {{- $fullName := include "ix.v1.common.lib.chart.names.fullname" . -}}
  {{- $servicemonitorName := $fullName -}}
  {{- $values := .Values.servicemonitor -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.metrics -}}
      {{- $values = . -}}
    {{- end -}}
  {{- end -}}
  {{- $servicemonitorLabels := $values.labels -}}
  {{- $servicemonitorAnnotations := $values.annotations -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $servicemonitorName = printf "%v-%v" $servicemonitorName $values.nameOverride -}}
  {{- end }}
---
apiVersion: {{ include "tc.v1.common.capabilities.servicemonitor.apiVersion" $ }}
kind: ServiceMonitor
metadata:
  name: {{ $servicemonitorName }}
  {{- $labels := (mustMerge ($servicemonitorLabels | default dict) (include "ix.v1.common.lib.metadata.allLabels" $ | fromYaml)) -}}
  {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $ "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end }}
  {{- $annotations := (mustMerge ($servicemonitorAnnotations | default dict) (include "ix.v1.common.lib.metadata.allAnnotations" $ | fromYaml)) -}}
  {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $ "annotations" $annotations) | trim) }}
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
      {{- include "ix.v1.common.lib.metadata.allLabels.selectorLabels" $ | nindent 6 }}
    {{- end }}
  endpoints:
    {{- tpl (toYaml $values.endpoints) $ | nindent 4 }}
{{- end -}}
