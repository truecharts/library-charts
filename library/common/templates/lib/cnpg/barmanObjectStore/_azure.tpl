{{- define "tc.v1.common.lib.cnpg.cluster.barmanObjectStoreConfig.azure" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}
  {{- $data := .data -}}

  {{- $fullname := include "tc.v1.common.lib.chart.names.fullname" $rootCtx -}}
  {{- $secretName := (printf "%s-cnpg-%s-provider-recovery-azure-creds" $fullname $objectData.shortName) -}}

  {{- $endpointURL := $objectData.recovery.endpointURL -}}
  {{- $destinationPath := $objectData.recovery.destinationPath -}}
  {{- if not $destinationPath -}}
    {{- if not $data.storageAccount -}}
      {{- fail (print "CNPG Recovery - You need to specify [azure.storageAccount] or [recovery.destinationPath]") -}}
    {{- end -}}
    {{- if not $data.serviceName -}}
      {{- fail (print "CNPG Recovery - You need to specify [azure.serviceName] or [recovery.destinationPath]") -}}
    {{- end -}}
    {{- if not $data.containerName -}}
      {{- fail (print "CNPG Recovery - You need to specify [azure.containerName] or [recovery.destinationPath]") -}}
    {{- end -}}
    {{- $destinationPath = (printf "https://%s.%s.core.windows.net/%s/%s" $data.storageAccount $data.serviceName $data.containerName (($data.path | default "/") | trimSuffix "/")) -}}
  {{- end }}
endpointURL: {{ $endpointURL }}
destinationPath: {{ $destinationPath }}
azureCredentials:
  connectionString:
    name: {{ $secretName }}
    key: CONNECTION_STRING
  storageAccount:
    name: {{ $secretName }}
    key: STORAGE_ACCOUNT
  storageKey:
    name: {{ $secretName }}
    key: STORAGE_KEY
  storageSasToken:
    name: {{ $secretName }}
    key: STORAGE_SAS_TOKEN
{{- end -}}
