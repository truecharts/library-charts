{{- define "tc.v1.common.lib.cnpg.cluster.barmanObjectStoreConfig.s3" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}
  {{- $data := .data -}}

  {{- $fullname := include "tc.v1.common.lib.chart.names.fullname" $rootCtx -}}
  {{- $secretName := (printf "%s-cnpg-%s-provider-recovery-s3-creds" $fullname $objectData.shortName) -}}

  {{- $endpointURL := $objectData.recovery.endpointURL -}}
  {{- $destinationPath := $objectData.recovery.destinationPath -}}
  {{- if not $destinationPath -}}
    {{- if not $data.bucket -}}
      {{- fail (print "CNPG Recovery - You need to specify [recovery.s3.bucket] or [recovery.destinationPath]") -}}
    {{- end -}}
    {{- $destinationPath = (printf "s3://%s/%s" $data.bucket (($data.path | default "/") | trimSuffix "/")) -}}
  {{- end -}}
  {{- if not $endpointURL -}}
    {{- if not $data.region -}}
      {{- fail (print "CNPG Recovery - You need to specify [recovery.s3.region] or [recovery.endpointURL]") -}}
    {{- end -}}
    {{- $endpointURL = (printf "https://s3.%s.amazonaws.com" $data.region) -}}
  {{- end }}
endpointURL: {{ $endpointURL }}
destinationPath: {{ $destinationPath }}
s3Credentials:
  accessKeyId:
    name: {{ $secretName }}
    key: ACCESS_KEY_ID
  secretAccessKey:
    name: {{ $secretName }}
    key: ACCESS_SECRET_KEY
{{- end -}}
