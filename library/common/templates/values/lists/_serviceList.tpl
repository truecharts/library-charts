{{- define "tc.v1.common.values.serviceList" -}}
  {{- $rootCtx := . -}}

  {{- range $idx, $svcValues := $rootCtx.Values.serviceList -}}
    {{- $svcName := (printf "svc-list-%s" (toString $idx)) -}}

    {{- with $svcValues.name -}}
      {{- $svcName = . -}}
    {{- end -}}

    {{- if not (hasKey $rootCtx.Values "service") -}}
      {{- $_ := set $rootCtx.Values "service" dict -}}
    {{- end -}}

    {{- range $idx, $portValues := $svcValues.ports -}}
      {{- $portName := (printf "port-list-%s" (toString $idx)) -}}

      {{- with $portValues.name -}}
        {{- $portName = . -}}
      {{- end -}}

      {{- if not (hasKey $svcValues "ports") -}}
        {{- $_ := set $svcValues "ports" dict -}}
      {{- end -}}

      {{- $_ := set $svcValues.ports $portName $portValues -}}

    {{- end -}}

    {{- $_ := set $rootCtx.Values.service $svcName $svcValues -}}

  {{- end -}}
{{- end -}}
