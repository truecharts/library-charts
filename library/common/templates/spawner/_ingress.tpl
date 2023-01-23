{{/* Renders the Ingress objects required by the chart */}}
{{- define "tc.v1.common.spawner.ingress" -}}
  {{/* Generate named ingresses as required */}}
  {{- range $name, $ingress := .Values.ingress -}}
    {{- if $ingress.enabled -}}
      {{- $ingressValues := $ingress -}}

      {{/* set defaults */}}
      {{- if and (not $ingressValues.nameOverride) (ne $name (include "tc.v1.common.lib.util.ingress.primary" $)) -}}
        {{- $_ := set $ingressValues "nameOverride" $name -}}
      {{- end -}}

      {{- $_ := set $ "ObjectValues" (dict "ingress" $ingressValues) -}}
      {{- include "tc.v1.common.class.ingress" $ -}}
      {{- if and ( $ingressValues.tls ) ( not $ingressValues.clusterIssuer ) -}}
      {{- range $index, $tlsValues :=  $ingressValues.tls -}}
        {{- if and ( $tlsValues.scaleCert ) ( $.Values.global.ixChartContext ) -}}
          {{- $nameOverride := ( printf "%v-%v" "tls" $index ) -}}

          {{- if $ingressValues.nameOverride -}}
            {{- $nameOverride = ( printf "%v-%v-%v" $ingressValues.nameOverride "tls" $index ) -}}
          {{- end -}}

          {{- $cert := dict -}}
          {{- $_ := set $cert "nameOverride" $nameOverride -}}
          {{- $_ := set $cert "id" .scaleCert -}}
          {{- include "ix.v1.common.certificate.secret" (dict "root" $ "cert" $cert "name" $cert.nameOverride) -}}
        {{- end -}}
      {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
