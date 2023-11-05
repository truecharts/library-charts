{{- define "tc.v1.common.lib.cnpg.cluster.backup" -}}
  {{- $objectData := .objectData -}}
  {{- $cnpgClusterName := (include "tc.v1.common.lib.cnpg.clusterName" (dict "objectData" $objectData)) }}
backup:
  target: {{ $objectData.backups.target }}
  retentionPolicy: {{ $objectData.backups.retentionPolicy }}
  barmanObjectStore:
    wal:
      compression: gzip
      encryption: AES256
    data:
      compression: gzip
      encryption: AES256
      jobs: {{ $objectData.backups.jobs | default 2 }}
    {{- $data := dict "chartFullname" $cnpgClusterName "scope" $objectData.backups -}}
    {{- include "tc.v1.common.lib.cnpg.cluster.barmanObjectStoreConfig" $data | nindent 4 -}}
{{- end -}}
