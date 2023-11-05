{{- define "tc.v1.common.lib.cnpg.clusterName" -}}
  {{- $objectData := .objectData -}}

  {{- $clusterName := $objectData.name -}}
  {{/* Append version to the cluster name if available */}}
  {{- if and $objectData.version (ne $objectData.version "legacy") -}}
    {{- $cnpgClusterName = printf "%s-%v" $objectData.name $objectData.version -}}
  {{- end -}}
  {{/* Append the recovery string to the cluster name if available */}}
  {{- if $objectData.recValue -}}
    {{- $cnpgClusterName = printf "%s-%s" $cnpgClusterName $objectData.recValue -}}
  {{- end -}}

  {{- $clusterName -}}
{{- end -}}
