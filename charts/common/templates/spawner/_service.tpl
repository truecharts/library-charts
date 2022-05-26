{{/*
Renders the Service objects required by the chart.
*/}}
{{- define "tc.common.v10.spawner.service" -}}
  {{- /* Generate named services as required */ -}}
  {{- range $name, $service := .Values.service }}
    {{- if $service.enabled -}}
      {{- $serviceValues := $service -}}

      {{/* set the default nameOverride to the service name */}}
      {{- if and (not $serviceValues.nameOverride) (ne $name (include "tc.common.v10.lib.util.service.primary" $)) -}}
        {{- $_ := set $serviceValues "nameOverride" $name -}}
      {{ end -}}

      {{- $_ := set $ "ObjectValues" (dict "service" $serviceValues) -}}
      {{- include "tc.common.v10.class.service" $ }}
    {{- end }}
  {{- end }}
{{- end }}
