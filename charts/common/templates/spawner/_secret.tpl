{{/*
Renders the Secret objects required by the chart.
*/}}
{{- define "common.spawner.secret" -}}
  {{- /* Generate named secrets as required */ -}}
  {{- range $name, $secret := .Values.secret }}
    {{- if $secret.enabled -}}
      {{- $secretValues := $secret -}}

      {{/* set the default nameOverride to the Secret name */}}
      {{- if not $secretValues.nameOverride -}}
        {{- $_ := set $secretValues "nameOverride" $name -}}
      {{ end -}}

      {{- $_ := set $ "ObjectValues" (dict "secret" $secretValues) -}}
      {{- include "common.classes.secret" $ }}
    {{- end }}
  {{- end }}
{{- end }}
