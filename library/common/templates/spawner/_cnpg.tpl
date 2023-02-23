{{/* Renders the cnpg objects required by the chart */}}
{{- define "tc.v1.common.spawner.cnpg" -}}
  {{/* Generate named cnpges as required */}}
  {{- range $name, $cnpg := .Values.cnpg -}}
    {{- if $cnpg.enabled -}}
      {{- $cnpgValues := $cnpg -}}
      {{- $cnpgName := include "tc.v1.common.lib.chart.names.fullname" $ -}}
      {{- $_ := set $cnpgValues "shortName" $name -}}

      {{/* set defaults */}}
      {{- $_ := set $cnpgValues "nameOverride" $name -}}

      {{- $cnpgName := printf "%v-cnpg-%v" $cnpgName $cnpgValues.nameOverride -}}

      {{- $_ := set $cnpgValues "name" $cnpgName -}}

      {{- $_ := set $ "ObjectValues" (dict "cnpg" $cnpgValues) -}}
      {{- include "tc.v1.common.class.cnpg.cluster" $ -}}

      {{- $_ := set $cnpgValues.pooler "type" "rw" -}}
      {{- if not $cnpgValues.acceptRO }}
      {{- include "tc.v1.common.class.cnpg.pooler" $ -}}
      {{- else }}
      {{- include "tc.v1.common.class.cnpg.pooler" $ -}}
      {{- $_ := set $cnpgValues.pooler "type" "ro" -}}
      {{- include "tc.v1.common.class.cnpg.pooler" $ -}}
      {{- end }}
    {{- end -}}
  {{- end -}}
{{- end -}}
