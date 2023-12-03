{{/* Renders the cnpg objects required by the chart */}}
{{- define "tc.v1.common.spawner.cnpg-old" -}}

  {{/* Generate named cnpges as required */}}
  {{- range $name, $cnpg := $.Values.cnpg -}}

    {{- if $enabled -}}

      {{/* Validate the object */}}
      {{/* Validate backup here as it used in Cluster too */}}
      {{- include "tc.v1.common.lib.cnpg.cluster.backup.validation" (dict "objectData" $objectData) -}}

      {{- if eq $objectData.mode "recovery" -}}
        {{- include "tc.v1.common.lib.cnpg.cluster.recovery.validation" (dict "objectData" $objectData) -}}
      {{- end -}}

      {{- if $objectData.monitoring.enablePodMonitor -}}

        {{- $poolerMetrics := include "tc.v1.common.lib.cnpg.metrics.pooler" (dict "poolerName" (printf "%s-rw" $objectData.name)) | fromYaml -}}
        {{- $_ := set $.Values.metrics (printf "cnpg-%s-rw" $objectData.shortName) $poolerMetrics -}}

        {{- if $objectData.pooler.acceptRO -}}
          {{- $poolerMetricsRO := include "tc.v1.common.lib.cnpg.metrics.pooler" (dict "poolerName" (printf "%s-ro" $objectData.name)) | fromYaml -}}
          {{- $_ := set $.Values.metrics (printf "cnpg-%s-ro" $objectData.shortName) $poolerMetricsRO -}}
        {{- end -}}

      {{- end -}}
    {{- end -}}

    {{- include "tc.v1.common.lib.cnpg.spawner.recovery.objectStore" (dict "objectData" $objectData "rootCtx" $) -}}


  {{- end -}}
{{- end -}}
