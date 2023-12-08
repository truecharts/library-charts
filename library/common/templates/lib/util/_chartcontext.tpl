{{/* Returns the primary Workload object */}}
{{- define "tc.v1.common.lib.util.chartcontext" -}}
  {{/* Create defaults */}}
  {{- $protocol := "http" -}}
  {{- $host := "127.0.0.1" -}}
  {{- $port := "443" -}}
  {{- $path := "/" -}}
  {{- $podCIDR := "172.16.0.0/16" -}}
  {{- $svcCIDR := "172.17.0.0/16" -}}

  {{/* TrueNAS SCALE specific code */}}
  {{- if $.Values.global.ixChartContext -}}
    {{- if $.Values.global.ixChartContext.kubernetes_config -}}
      {{- $podCIDR = $.Values.global.ixChartContext.kubernetes_config.cluster_cidr -}}
      {{- $svcCIDR = $.Values.global.ixChartContext.kubernetes_config.service_cidr -}}
    {{- end -}}
  {{- else -}}
    {{/* TODO: Find ways to implement CIDR detection */}}
  {{- end -}}

  {{/* If there is ingress, get data from the primary */}}
  {{- $primaryIngressName := include "tc.v1.common.lib.util.ingress.primary" (dict "rootCtx" $) -}}
  {{- $primaryIngress := (get $.Values.ingress $primaryIngressName) -}}
  {{- with $primaryIngress -}}
    {{- $firstHost := ((.hosts | default list) | mustFirst) -}}
    {{- if $firstHost -}}
      {{- $host = tpl $firstHost.host $ -}}
      {{- $firstPath := (($firstHost.paths | default list) | mustFirst) -}}
      {{- if $firstPath -}}
        {{- $path = $firstPath.path -}}
      {{- end -}}
    {{- end -}}

    {{- if and .integrations .integrations.traefik -}}
      {{- $enabled := true -}}
      {{- if and (hasKey .integrations.traefik "enabled") (kindIs "bool" .integrations.traefik.enabled) -}}
        {{- $enabled = .integrations.traefik.enabled -}}
      {{- end -}}

      {{- if $enabled -}}
        {{- $entrypoints := (.integrations.traefik.entrypoints | default (list "websecure")) -}}
        {{- if mustHas "websecure" $entrypoints -}}
          {{- $port = "443" -}}
        {{- else if mustHas "web" $entrypoints -}}
          {{- $port = "80" -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}

    {{- if and .integrations .integrations.certManager .integrations.certManager.enabled -}}
      {{- $protocol = "https" -}}
      {{- $port = "443" -}}
    {{- end -}}

    {{- $tls := ((.tls | default list) | mustFirst) -}}
    {{- if (or $tls.secretName $tls.scaleCert $tls.certificateIssuer $tls.clusterCertificate) -}}
      {{- $protocol = "https" -}}
      {{- $port = "443" -}}
    {{- end -}}
  {{- end -}}

  {{/* If there is no ingress, we have to use service */}}
  {{- if not $primaryIngress -}}
    {{- $primaryServiceName := include "tc.v1.common.lib.util.service.primary" (dict "rootCtx" $) -}}
    {{- $primaryService := (get $.Values.service $primaryServiceName) -}}
    {{- $primaryPort := dict -}}
    {{- if $primaryService -}}
      {{- $primaryPortName := include "tc.v1.common.lib.util.service.ports.primary" (dict "rootCtx" $ "svcName" $primaryServiceName) -}}
      {{- $primaryPort = (get $primaryService.ports $primaryPortName) -}}

      {{- $port = tpl ($primaryPort.port | toString) $ -}}

      {{- if mustHas $primaryPort.type (list "http" "https") -}}
        {{- $protocol = $primaryPort.type -}}
      {{- else -}}
        {{- $protocol = "http" -}}
      {{- end -}}

      {{- if eq $primaryService.type "LoadBalancer" -}}
        {{- with $primaryService.loadBalancerIP -}}
          {{- $host = tpl . $ | toString -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{/* URL Will not include the path. */}}
  {{- $url := printf "%s://%s:%s" $protocol $host $port -}}

  {{- $port = $port | toString -}}
  {{- if eq $port "443" -}}
    {{- $url = $url | trimSuffix ":443" -}}
    {{- $url = $url | replace $protocol "https" -}}
    {{- $protocol = "https" -}}
  {{- end -}}

  {{- if eq $port "80" -}}
    {{- $url = $url | trimSuffix ":80" -}}
    {{- $url = $url | replace $protocol "http" -}}
    {{- $protocol = "http" -}}
  {{- end -}}

  {{- $context := (dict
    "podCIDR" $podCIDR
    "svcCIDR" $svcCIDR
    "appUrl" $url
    "appHost" $host
    "appPort" $port
    "appPath" $path
    "appProtocol" $protocol
  ) -}}

  {{- $_ := set $.Values "chartContext" $context -}}
  {{- $_ := set $.Values.configmap "chart-context" (dict
    "enabled" true
    "data" $context
  ) -}}
{{- end -}}
