{{/*
Renders the configMap objects required by the chart.
*/}}
{{- define "tc.common.v10.spawner.configmap" -}}
  {{- /* Generate named configMaps as required */ -}}
  {{- range $name, $configmap := .Values.configmap }}
    {{- if $configmap.enabled -}}
      {{- $configmapValues := $configmap -}}

      {{/* set the default nameOverride to the configMap name */}}
      {{- if not $configmapValues.nameOverride -}}
        {{- $_ := set $configmapValues "nameOverride" $name -}}
      {{ end -}}

      {{- $_ := set $ "ObjectValues" (dict "configmap" $configmapValues) -}}
      {{- include "tc.common.v10.class.configmap" $ }}
    {{- end }}
  {{- end }}
{{- end }}
