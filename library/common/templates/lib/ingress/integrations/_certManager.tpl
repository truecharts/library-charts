{{- define "tc.v1.common.lib.ingress.integration.certManager" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}

  {{- $certManager := $objectData.integrations.certManager -}}

  {{- if $certManager.enabled -}}
    {{- include "tc.v1.common.lib.ingress.integration.certManager.validate" (dict "objectData" $objectData) -}}

    {{- $_ := set $objectData.annotations "cert-manager.io/cluster-issuer" $certManager.clusterIssuer -}}
    {{- $_ := set $objectData.annotations "cert-manager.io/private-key-rotation-policy" "Always" -}}

  {{- end -}}
{{- end -}}

{{- define "tc.v1.common.lib.ingress.integration.certManager.validate" -}}
  {{- $objectData := .objectData -}}

  {{- $certManager := $objectData.integrations.certManager -}}

  {{- if not $certManager.clusterIssuer -}}
    {{- fail "Ingress - Expected a non-empty [integrations.certManager.clusterIssuer]" -}}
  {{- end -}}

  {{- if not (kindIs "string" $certManager.clusterIssuer) -}}
    {{- fail (printf "Ingress - Expected [integrations.certManager.clusterIssuer] to be a [string], but got [%s]" (kindOf $certManager.clusterIssuer)) -}}
  {{- end -}}

{{- end -}}
