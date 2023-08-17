{{- define "tc.v1.common.lib.cnpg.secret.azure" -}}
enabled: true
data:
  AZURE_CONNECTION_STRING: {{ .connectionString | quote }}
  AZURE_STORAGE_ACCOUNT: {{ .storageAccount | quote }}
  AZURE_STORAGE_KEY: {{ .storageKey | quote }}
  AZURE_STORAGE_SAS_TOKEN: {{ .storageSasToken | quote }}
{{- end -}}
