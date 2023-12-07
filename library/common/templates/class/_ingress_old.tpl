{{/*
This template serves as a blueprint for all Ingress objects that are created
within the common library.
*/}}
{{- define "tc.v1.common.class.ingress.old" -}}
  {{- $fullName := include "tc.v1.common.lib.chart.names.fullname" . -}}
  {{- $values := dict -}}
  {{- $ingressName := "" -}}


  {{/* Get the name of the primary service, if any */}}
  {{- $primaryServiceName := (include "tc.v1.common.lib.util.service.primary" (dict "services" .Values.service "root" .)) -}}
  {{/* Get service values of the primary service, if any */}}
  {{- $primaryService := get .Values.service $primaryServiceName -}}
  {{- $defaultServiceName := $fullName -}}

  {{- if and (hasKey $primaryService "nameOverride") $primaryService.nameOverride -}}
    {{- $defaultServiceName = printf "%v-%v" $defaultServiceName $primaryService.nameOverride -}}
  {{- end -}}
  {{- $defaultServicePort := get $primaryService.ports (include "tc.v1.common.lib.util.service.ports.primary" (dict "svcValues" $primaryService "svcName" $primaryServiceName )) -}}


---

spec:
  {{- if $values.certificateIssuer }}
  tls:
    {{- range $index, $hostsValues := $values.hosts }}
    - hosts:
      - {{ tpl $hostsValues.host $ | quote }}
      secretName: {{ ( printf "%v-%v-%v" $ingressName "tls" $index ) }}
    {{- end -}}
  {{- else if $values.tls }}
  tls:
    {{- range $index, $tlsValues :=  $values.tls }}
    {{- $tlsName := ( printf "%v-%v" "tls" $index ) }}
    - hosts:
        {{- range $tlsValues.hosts }}
        - {{ tpl . $ | quote }}
        {{- end -}}
      {{- if $tlsValues.certificateIssuer }}
      secretName: {{ printf "%v-%v" $ingressName $tlsName }}
      {{- else if  and ($tlsValues.scaleCert) ($.Values.global.ixChartContext) -}}
        {{- $cert := dict }}
        {{- $_ := set $cert "id" $tlsValues.scaleCert }}
        {{- $_ := set $cert "nameOverride" $tlsName }}
      secretName: {{ printf "%s-tls-%v" (include "tc.v1.common.lib.chart.names.fullname" $) $index }}
      {{- else if .clusterCertificate }}
      secretName: clusterissuer-templated-{{ tpl .clusterCertificate $ }}
      {{- else if .secretName }}
      secretName: {{ tpl .secretName $ | quote }}
      {{- end -}}
    {{- end -}}
  {{- end }}
  rules:
  {{- range $values.hosts }}
        paths:
          {{- range .paths -}}
            {{- $service := $defaultServiceName -}}
            {{- $port := $defaultServicePort.port -}}
            {{- if .service -}}
              {{- $service = default $service .service.name -}}
              {{- $port = default $port .service.port -}}
            {{- end }}
          {{- end -}}
  {{- end -}}


{{- end -}}
