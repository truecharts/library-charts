{{- define "tc.v1.common.lib.webhook" -}}
  {{- $webhook := .webhook -}}
  {{- $rootCtx := .rootCtx }}
- name: {{ $webhook.name }}
  {{- with $webhook.failurePolicy }}
  failurePolicy: {{ tpl . $rootCtx }}
  {{- end -}}
  {{- with $webhook.matchPolicy }}
  matchPolicy: {{ tpl . $rootCtx }}
  {{- end -}}
  {{- with $webhook.reinvocationPolicy }}
  reinvocationPolicy: {{ tpl . $rootCtx }}
  {{- end -}}
  {{- with $webhook.sideEffects }}
  sideEffects: {{ tpl . $rootCtx }}
  {{- end -}}
  {{- with $webhook.timeoutSeconds }}
    {{- $timeout := . -}}
    {{- if (kindIs "string" $timeout) -}}
      {{- $timeout = tpl . $rootCtx -}}
    {{- end }}
  timeoutSeconds: {{ $timeout }}
  {{- end -}}
  {{- include "tc.v1.common.lib.webhook.admissionReviewVersions" (dict "admissionReviewVersions" $webhook.admissionReviewVersions) | trim | nindent 2 -}}
  {{- include "tc.v1.common.lib.webhook.clientConfig" (dict "clientConfig" $webhook.clientConfig) | trim | nindent 2 -}}
  {{- with $webhook.rules }}
  rules:
    {{- tpl (toYaml $webhook.rules) $rootCtx | nindent 2 -}}
  {{- end -}}
  {{- with $webhook.namespaceSelector }}
  namespaceSelector:
    {{- tpl (toYaml $webhook.namespaceSelector) $rootCtx | nindent 2 -}}
  {{- end -}}
  {{- with $webhook.objectSelector }}
  objectSelector:
    {{- tpl (toYaml $webhook.objectSelector) $rootCtx | nindent 2 -}}
  {{- end -}}
{{- end -}}
{{/*TODO: rules */}}
