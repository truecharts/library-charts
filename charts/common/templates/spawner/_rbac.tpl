{{/*
Renders the configMap objects required by the chart.
*/}}
{{- define "common.spawner.rbac" -}}
  {{- /* Generate named rbac as required */ -}}
  {{- range $name, $rbac := .Values.rbac }}
    {{- if $rbac.enabled -}}
      {{- $rbacValues := $rbac -}}

      {{/* set the default nameOverride to the rbac name */}}
      {{- if and (not $rbacValues.nameOverride) (ne $name (include "common.helper.rbac.primary" $)) -}}
        {{- $_ := set $rbacValues "nameOverride" $name -}}
      {{ end -}}

      {{- $_ := set $ "ObjectValues" (dict "rbac" $rbacValues) -}}
      {{- include "common.class.rbac" $ }}
    {{- end }}
  {{- end }}
{{- end }}
