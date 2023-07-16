{{- define "tc.v1.common.lib.webhook.clientConfig" -}}
  {{- $clientConfig := .clientConfig }}
clientConfig:
  {{- if $clientConfig.caBundle }}
  caBundle: {{ $clientConfig.caBundle | quote }}
  {{- end -}}
  {{- if $clientConfig.url }}
  url: {{ $clientConfig.url | quote }}
  {{- end -}}
  {{- if $clientConfig.service }}
  service:
    name: {{ $clientConfig.service.name }}
    namespace: {{ $clientConfig.service.namespace }}
    {{- with $clientConfig.service.path }}
    path: {{ . | quote }}
    {{- end -}}
    {{- with $clientConfig.service.port }}
    port: {{ . }}
    {{- end -}}
  {{- end -}}
{{- end -}}
