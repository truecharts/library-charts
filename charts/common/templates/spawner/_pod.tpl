{{/*
Renders the pod objects required by the chart.
*/}}
{{- define "common.spawner.pod" -}}
  {{- /* Generate named pods as required */ -}}
  {{- range $name, $pod := .Values.pod }}
    {{- if $pod.enabled -}}
      {{- $podValues := $pod -}}

      {{/* set the default nameOverride to the pod name */}}
      {{- if and (not $podValues.nameOverride) (ne $name (include "common.helper.pod.primary" $)) -}}
        {{- $_ := set $podValues "nameOverride" $name -}}
      {{ end -}}

      {{- $_ := set $ "ObjectValues" (dict "pod" $podValues) -}}

      {{ $type := "deployment" }}
      {{- if $pod.type }}
        {{ $type = $pod.type }}
      {{- end }}

      {{- if eq $type "deployment" }}
        {{- include "common.class.deployment" $ | nindent 0 }}
      {{ else if eq $type "daemonset" }}
        {{- include "common.daemonset" $ | nindent 0 }}
      {{ else if eq $type "statefulset"  }}
        {{- include "common.class.statefulset" $ | nindent 0 }}
      {{ else }}
        {{- fail (printf "Not a valid controller.type (%s)" $type) }}
      {{- end -}}
    {{- end }}
  {{- end }}
{{- end }}
