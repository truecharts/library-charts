{{- define "tc.v1.common.class.cnpg.pooler" -}}
  {{- $values := .Values.cnpg -}}
  {{- $backupValues := .Values.cnpg -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.cnpg -}}
      {{- $values = . -}}
    {{- end -}}
  {{- end -}}

  {{- $cnpgClusterName := $values.name -}}
  {{- if and $cnpg.version ( ne $cnpg.version "legacy" ) -}}
    {{- $cnpgClusterName = printf "$v-%v" $values.name $values.version -}}
  {{- end -}}

  {{- if $values.recValue -}}
    {{- $cnpgClusterName = printf "$v-%v" cnpgClusterName $values.recValue -}}
  {{- end -}}

  {{- $cnpgName := $values.cnpgName -}}
  {{- $cnpgbackupName := $values.backupName -}}
  {{- $cnpgLabels := $values.labels -}}
  {{- $cnpgAnnotations := $values.annotations -}}
  {{- $cnpgbackupLabels := $values.backupLabels -}}
  {{- $cnpgbackupAnnotations := $values.backupAnnotations -}}
---
apiVersion: {{ include "tc.v1.common.capabilities.cnpg.pooler.apiVersion" $ }}
kind: Pooler
metadata:
  name: {{ printf "%v-backup-%v" $values.name $cnpgbackupName }}
  namespace: {{ $.Values.namespace | default $.Values.global.namespace | default $.Release.Namespace }}
  {{- $labels := (mustMerge ($cnpgbackupLabels | default dict) ($cnpgLabels | default dict) (include "tc.v1.common.lib.metadata.allLabels" $ | fromYaml)) }}
  labels:
    cnpg.io/cluster: {{ $cnpgClusterName }}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $ "labels" $labels) | trim) }}
    {{- . | nindent 4 }}
  {{- end }}
  {{- $annotations := (mustMerge ($cnpgbackupAnnotations | default dict) ($cnpgLabels | default dict) (include "tc.v1.common.lib.metadata.allAnnotations" $ | fromYaml)) }}
  annotations:
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $ "annotations" $annotations) | trim) }}
    {{- . | nindent 4 }}
  {{- end }}
spec:
  cluster:
    name: {{ $cnpgClusterName }}
{{- end -}}
