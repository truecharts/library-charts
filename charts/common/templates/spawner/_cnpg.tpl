{{/*
Renders the cnpg objects required by the chart.
*/}}
{{- define "tc.common.spawner.cnpg" -}}
  {{- /* Generate named databases as required */ -}}
  {{- range $name, $cnpg := .Values.cnpg }}
    {{- if $cnpg.enabled -}}
      {{- $cnpgValues := $cnpg -}}

      {{/* set the default nameOverride to the cnpg name */}}
      {{- if and (not $cnpgValues.nameOverride) (ne $name (include "tc.common.lib.util.cnpg.primary" $)) -}}
        {{- $_ := set $cnpgValues "nameOverride" $name -}}
      {{ end -}}

      {{- $_ := set $ "ObjectValues" (dict "cnpg" $cnpgValues) -}}
      {{- include "tc.common.class.cnpg" $ }}
    {{- end }}
  {{- end }}
{{- end }}
