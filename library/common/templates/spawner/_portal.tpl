{{/* Portal Spawwner */}}
{{/* Call this template:
{{ include "tc.v1.common.spawner.portal" $ -}}
*/}}

{{- define "tc.v1.common.spawner.portal" -}}

  {{- range $name, $portal := .Values.portal -}}

    {{- if $portal.enabled -}}

      {{/* Create a copy of the portal */}}
      {{- $objectData := (mustDeepCopy $portal) -}}

      {{/* Create defaults */}}
      {{- $protocol := "https" -}}
      {{- $host := "$node_ip" -}}
      {{- $port := "443" -}}
      {{- $suffix := $objectData.urlSuffix -}}
      {{- $url := "" -}}

      {{/* Get service, default to primary */}}
      {{- $selectedService := fromYaml ( include "tc.v1.common.lib.helpers.getSelectedServiceValues" (dict "rootCtx" $ "objectData" $objectData.targetSeleector.service ) ) -}}

      {{/* read loadbalancer IP's for metallb */}}
      {{- if eq $selectedService.type "LoadBalancer" -}}
        {{- with $selectedService.loadBalancerIP -}}
          {{- $host = toString . -}}
        {{- end -}}

      {{/* set temporary storage for port name and port */}}
      {{- $targetPort := "" -}}
      {{- $selectedPort := "" -}}

      {{/* Fetch port values */}}
      {{- if $objectData.targetSelector.port -}}
      {{- $targetPort := $objectData.targetSeleector.port -}}
      {{- else -}}
      {{- $targetPort := include "tc.v1.common.lib.util.service.ports.primary" $selectedService -}}
      {{- end -}}

      {{- $selectedPort = get $selectedService.port $targetPort -}}

      {{/* store port number */}}
      {{- $port = $selectedPort.port -}}
      {{- end -}}


      {{/* set temporary storage for ingress name and port */}}
      {{- $targetIngress := "" -}}
      {{- $selectedIngress := "" -}}

      {{/* Fetch ingress values */}}
      {{- if $objectData.targetSelector.ingress -}}
      {{- $targetIngress := $objectData.targetSelector.ingress -}}
      {{- else -}}
      {{- $targetIngress := include "tc.v1.common.lib.util.service.ingress.primary" $ -}}
      {{- end -}}
      {{- $selectedIngress = get .Values.ingress $targetIngress -}}

      {{/* store host from ingress number */}}
      {{- if $selectedIngress.enabled -}}
      {{- with (index $selectedIngress.hosts 0) }}
         {{- $host = .host -}}
      {{- end }}
      {{- end }}

      {{/* Apply overrides */}}
      {{- if $objectData.override.protocol -}}
        {{- $protocol = $objectData.override.protocol -}}
      {{- end -}}

      {{- if $objectData.override.host -}}
        {{- $host = $objectData.override.host -}}
      {{- end -}}

      {{- if $objectData.override.port -}}
        {{- $port = $objectData.override.port -}}
      {{- end -}}



      {{/* sanitise */}}
      {{- if eq $port "443" -}}
        {{- $protocol = "https" -}}
      {{- end -}}

      {{- if eq $port "80" -}}
        {{- $protocol = "http" -}}
      {{- end -}}

      {{- if or ( eq $protocol "https" ) ( eq $protocol "http" ) -}}
        {{- $port = "" -}}
      {{- end -}}

      {{/* Construct URL*/}}
      {{- if $port -}}
      {{- $url = printf "%s://%s:%s/%s" $protocol $host $port $suffix -}}
      {{- else -}}
      {{- $url = printf "%s://%s/%s" $protocol $host $suffix -}}
      {{- end -}}

    {{- end -}}

  {{- end -}}

{{- end -}}
