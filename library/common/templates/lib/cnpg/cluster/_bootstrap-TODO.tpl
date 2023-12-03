{{/* Recovery Template, called when mode is recovery */}}
{{- define "tc.v1.common.lib.cnpg.cluster.bootstrap.recovery" }}
  {{- $objectData := .objectData -}}
recovery:
  secret:
    name: {{ printf "%s-user" $objectData.clusterName }}
  database: {{ $objectData.database }}
  owner: {{ $objectData.user }}
  {{- if $objectData.recovery.pitrTarget -}}
    {{- with $objectData.recovery.pitrTarget.time }}
  recoveryTarget:
    targetTime: {{ . }}
    {{- end -}}
  {{- end -}}
  {{- if eq $objectData.recovery.method "backup" -}}
  backup:
    name: {{ $objectData.recovery.backupName }}
  {{- end -}}
  {{- if eq $objectData.recovery.method "object_store" -}}
  source: objectStoreRecoveryCluster
  {{- end -}}
{{- end -}}

{{/* Recovery from externalClusters Template, called when mode is recovery */}}
{{- define "tc.v1.common.lib.cnpg.cluster.bootstrap.recovery.externalCluster" }}
  {{- $objectData := .objectData -}}

  {{- if eq $objectData.recovery.method "object_store" }}
externalClusters:
  - name: objectStoreRecoveryCluster
    barmanObjectStore:
      serverName: {{ $objectData.recovery.serverName }}
      {{- $data := dict "chartFullname" $objectData.clusterName "scope" $objectData.recovery "secretSuffix" "-recovery" -}}
      {{- include "tc.v1.common.lib.cnpg.cluster.barmanObjectStoreConfig" $data | nindent 6 -}}
  {{- end -}}
{{- end -}}
