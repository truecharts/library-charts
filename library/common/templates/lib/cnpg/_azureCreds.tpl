{{- define "tc.v1.common.lib.cnpg.secret.azure" -}}
{{- $creds := .creds -}}
{{- $reqKeys := (list "connectionString" "storageAccount" "storageKey" "storageSasToken") -}}
{{- range $r := $reqKeys -}}
  {{- if get $creds $r -}}
    {{- fail (printf "CNPG - Azure Creds requires [%s] to be defined and non-empty" $r) -}}
  {{- end -}}
{{- end }}
enabled: true
data:
  AZURE_CONNECTION_STRING: {{ $creds.connectionString | quote }}
  AZURE_STORAGE_ACCOUNT: {{ $creds.storageAccount | quote }}
  AZURE_STORAGE_KEY: {{ $creds.storageKey | quote }}
  AZURE_STORAGE_SAS_TOKEN: {{ $creds.storageSasToken | quote }}
{{- end -}}
