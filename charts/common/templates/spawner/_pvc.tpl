{{/*
Renders the Persistent Volume Claim objects required by the chart.
*/}}
{{- define "tc.common.v10.spawner.pvc" -}}
  {{- /* Generate pvc as required */ -}}
  {{- range $index, $PVC := .Values.persistence }}
    {{- if and $PVC.enabled (eq (default "pvc" $PVC.type) "pvc") (not $PVC.existingClaim) -}}
      {{- $persistenceValues := $PVC -}}
      {{- if not $persistenceValues.nameOverride -}}
        {{- $_ := set $persistenceValues "nameOverride" $index -}}
      {{- end -}}
      {{- $_ := set $ "ObjectValues" (dict "persistence" $persistenceValues) -}}
      {{- include "tc.common.v10.class.pvc" $ | nindent 0 -}}
    {{- end }}
  {{- end }}
{{- end }}
