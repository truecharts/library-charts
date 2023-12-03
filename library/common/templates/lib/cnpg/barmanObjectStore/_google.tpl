{{- define "tc.v1.common.lib.cnpg.cluster.barmanObjectStoreConfig.google" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}
  {{- $data := .data -}}

  {{- $fullname := include "tc.v1.common.lib.chart.names.fullname" $rootCtx -}}
  {{- $secretName := (printf "%s-cnpg-%s-provider-recovery-google-creds" $fullname $objectData.shortName) -}}

  {{- $gkeEnv := false -}}
  {{- if (kindIs "bool" $data.gkeEnvionment) -}}
    {{- $gkeEnv = $data.gkeEnvionment -}}
  {{- end -}}

  {{- $endpointURL := $objectData.recovery.endpointURL -}}
  {{- $destinationPath := $objectData.recovery.destinationPath -}}
  {{- if not $destinationPath -}}
    {{- if not $data.bucket -}}
      {{- fail (print "CNPG Recovery - You need to specify [recovery.google.bucket] or [recovery.destinationPath]") -}}
    {{- end -}}
    {{- $destinationPath = (printf "gs://%s/%s" $data.bucket (($data.path | default "/") | trimSuffix "/")) -}}
  {{- end }}
endpointURL: {{ $endpointURL }}
destinationPath: {{ $destinationPath }}
googleCredentials:
  gkeEnvironment: {{ $gkeEnv }}
  applicationCredentials:
    name: {{ $secretName }}
    key: APPLICATION_CREDENTIALS
{{- end -}}
