{{- define "tc.v1.common.lib.velero.provider.secret" -}}
  {{- $rootCtx := .rootCtx }}
  {{- $objectData := .objectData -}}

  {{- $creds := "" -}} {{/* TODO: Provider should probably be velero.io/aws or we should map it  */}}
  {{- if and (eq ($objectData.provider | toString) "aws") $objectData.credential.aws -}}
    {{- $creds = (include "tc.v1.common.lib.velero.provider.aws.secret" (dict "creds" $objectData.credential.aws) | fromYaml).data -}}
  {{- end -}}

  {{/* If we matched a provider, create the secret */}}
  {{- if $creds -}}
    {{- $secretData := (dict
          "name" (printf "vsl-%s" $objectData.name)
          "labels" $objectData.labels
          "annotations" $objectData.annotations
          "data" (dict "cloud" $creds)
      ) -}}

    {{/* Create the secret */}}
    {{- include "tc.v1.common.class.secret" (dict "rootCtx" $rootCtx "objectData" $secretData) -}}

    {{/* Update the credential object with the name and key */}}
    {{- $_ := set $objectData.credential "name" (printf "vsl-%s" $objectData.name) -}}
    {{- $_ := set $objectData.credential "key" "cloud" -}}
  {{- end -}}

{{- end -}}
