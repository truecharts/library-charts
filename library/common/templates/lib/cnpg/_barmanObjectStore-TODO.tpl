{{- define "tc.v1.common.lib.cnpg.cluster.barmanObjectStoreConfig" -}}

{{- $chartFullname := .chartFullname -}}
{{- $destPath := .scope.destinationPath -}}
{{- $endpointUrl := .scope.endpointURL -}}

{{- if eq .scope.provider "s3" -}}
  {{- if or (not (hasKey .scope "s3")) (not .scope.s3) -}}
    {{- fail "CNPG Barman - Expected key [s3] to exist and not be empty when provider is [s3]" -}}
  {{- end -}}
  {{- if not $endpointUrl -}}
    {{- if not .scope.s3.region -}}
      {{- fail "CNPG Barman - You need to specify [s3.region] when [endpointURL] is empty" -}}
    {{- end -}}
    {{- $endpointUrl = (printf "https://s3.%s.amazonaws.com" .scope.s3.region) -}}
  {{- end -}}

  {{- if not $destPath -}}
    {{- if not .scope.s3.bucket -}}
      {{- fail "CNPG Barman - You need to specify [s3.bucket] when [destinationPath] is empty" -}}
    {{- end -}}
    {{- $destPath = (printf "s3://%s/%s" .scope.s3.bucket ((.scope.s3.path | default "/") | trimSuffix "/")) -}}
  {{- end }}
  s3Credentials:
    accessKeyId:
      name: {{ printf "%s-backup-s3%s-creds" $chartFullname .secretSuffix }}
      key: ACCESS_KEY_ID
    secretAccessKey:
      name: {{ printf "%s-backup-s3%s-creds" $chartFullname .secretSuffix }}
      key: ACCESS_SECRET_KEY
{{- else if eq .scope.provider "azure" -}}
  {{- if or (not (hasKey .scope "azure")) (not .scope.azure) -}}
    {{- fail "CNPG Barman - Expected key [azure] to exist and not be empty when provider is [azure]" -}}
  {{- end -}}
  {{- if not $destPath -}}
    {{- if not .scope.azure.storageAccount -}}
      {{- fail "CNPG Barman - You need to specify [azure.storageAccount] when [destinationPath] is empty" -}}
    {{- end -}}
    {{- $destPath = (printf "https://%s.%s.core.windows.net/%s/%s" .scope.azure.storageAccount .scope.azure.serviceName .scope.azure.containerName ((.scope.azure.path | default "/") | trimSuffix "/")) -}}
  {{- end }}
  azureCredentials:
    connectionString:
      name: {{ printf "%s-backup-azure%s-creds" $chartFullname .secretSuffix }}
      key: AZURE_CONNECTION_STRING
    storageAccount:
      name: {{ printf "%s-backup-azure%s-creds" $chartFullname .secretSuffix }}
      key: AZURE_STORAGE_ACCOUNT
    storageKey:
      name: {{ printf "%s-backup-azure%s-creds" $chartFullname .secretSuffix }}
      key: AZURE_STORAGE_KEY
    storageSasToken:
      name: {{ printf "%s-backup-azure%s-creds" $chartFullname .secretSuffix }}
      key: AZURE_STORAGE_SAS_TOKEN
{{- else if eq .scope.provider "google" -}}
  {{- if or (not (hasKey .scope "google")) (not .scope.google) -}}
    {{- fail "CNPG Barman - Expected key [google] to exist and not be empty when provider is [google]" -}}
  {{- end -}}
  {{- if not $destPath -}}
    {{- if not .scope.google.bucket -}}
      {{- fail "CNPG Barman - You need to specify [google.bucket] when [destinationPath] is empty" -}}
    {{- end -}}
    {{- $destPath = (printf "gs://%s/%s" .scope.google.bucket ((.scope.google.path | default "/") | trimSuffix "/")) -}}
  {{- end }}
  googleCredentials:
    gkeEnvironment: {{ .scope.google.gkeEnvironment }}
    applicationCredentials:
      name: {{ printf "%s-backup-google%s-creds" $chartFullname .secretSuffix }}
      key: APPLICATION_CREDENTIALS
{{- end }}
  endpointURL: {{ $endpointUrl }}
  destinationPath: {{ $destPath }}
{{- end -}}
