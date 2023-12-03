{{/* Recovery from externalClusters Template, called when mode is recovery */}}
{{- define "tc.v1.common.lib.cnpg.cluster.bootstrap.recovery.externalCluster" }}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- if eq $objectData.recovery.method "object_store" }}
externalClusters:
  - name: objectStoreRecoveryCluster
    barmanObjectStore:

    {{- $provider := $objectData.recovery.provider -}}
    {{/* Fetch provider data */}}
    {{- $data := (get $objectData.recovery $provider) -}}
    {{- include (printf "tc.v1.common.lib.cnpg.cluster.barmanObjectStoreConfig.%s" $provider) (dict "rootCtx" $rootCtx "objectData" $objectData "data" $data "type" "recovery") | nindent 6 -}}
  {{- end -}}
{{- end -}}
