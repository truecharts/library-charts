{{/*
Renders the configMap objects required by the chart.
*/}}
{{- define "common.spawner.hpa" -}}
  {{- /* Generate named configMaps as required */ -}}
  {{- range $name, $configmap := .Values.horizontalPodAutoscaler }}
    {{- if $hpa.enabled -}}
      {{- $hpaValues := $hpa -}}

      {{/* set the default nameOverride to the hpa name */}}
      {{- if not $hpaValues.nameOverride -}}
        {{- $_ := set $hpaValues "nameOverride" $name -}}
      {{ end -}}

      {{- $_ := set $ "ObjectValues" (dict "hpa" $hpaValues) -}}
      {{- include "common.classes.hpa" $ }}
    {{- end }}
  {{- end }}
{{- end }}
