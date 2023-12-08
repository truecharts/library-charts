{{/* Returns the primary service object */}}
{{- define "tc.v1.common.lib.util.service.primary" -}}
  {{- $rootCtx := .rootCtx -}}

  {{- $result := "" -}}
  {{- range $name, $service := $rootCtx.Values.service -}}
    {{- $enabled := (include "tc.v1.common.lib.util.enabled" (dict
              "rootCtx" $rootCtx "objectData" $service
              "name" $name "caller" "Primary service Util"
              "key" "service")) -}}

    {{- if eq $enabled "true" -}}
      {{- if $service.primary -}}
        {{/*
          While this will overwrite if there are
          more than 1 primary service, its not an issue
          as there is validation down the line that will
          fail if there are more than 1 primary service
        */}}
        {{- $result = $name -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $result -}}
{{- end -}}
