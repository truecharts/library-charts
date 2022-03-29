{{/*
Renders the Service objects required by the chart.
*/}}
{{- define "common.spawner.service" -}}
  {{- /* Generate named services as required */ -}}
  {{- range $name, $service := .Values.service }}
    {{- if $service.enabled -}}
      {{- $serviceValues := $service -}}

      {{/* set the default nameOverride to the service name */}}
      {{- if and (not $serviceValues.nameOverride) (ne $name (include "common.helper.service.primary" $)) -}}
        {{- $_ := set $serviceValues "nameOverride" $name -}}
      {{ end -}}

      {{- $_ := set $ "ObjectValues" (dict "service" $serviceValues) -}}
      {{- include "common.classes.service" $ }}
    {{- end }}
  {{- end }}
{{- end }}
