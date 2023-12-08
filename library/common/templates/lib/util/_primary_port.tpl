{{/* A dict containing .values and .serviceName is passed when this function is called */}}
{{/* Return the primary port for a given Service object. */}}
{{- define "tc.v1.common.lib.util.service.ports.primary" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $svcName := .svcName -}}

  {{- $result := "" -}}
  {{- $serviceName := include "tc.v1.common.lib.util.service.primary" (dict "rootCtx" $rootCtx) -}}
  {{- $service := (get $rootCtx.Values.service $serviceName) -}}

  {{- range $name, $port := $service.ports -}}
    {{- $enabled := (include "tc.v1.common.lib.util.enabled" (dict
              "rootCtx" $rootCtx "objectData" $port
              "name" $name "caller" "Primary Port Util"
              "key" (printf "service.%s.ports" $serviceName))) -}}

    {{- if eq $enabled "true" -}}
      {{- if $port.primary -}}
        {{/*
          While this will overwrite if there are
          more than 1 primary port, its not an issue
          as there is validation down the line that will
          fail if there are more than 1 primary port
        */}}
        {{- $result = $name -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $result -}}
{{- end -}}
