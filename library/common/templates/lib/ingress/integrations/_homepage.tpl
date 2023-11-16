{{/* Ingress Homepage Integration */}}
{{/* Call this template:
{{ include "tc.v1.common.lib.ingress.integration.homepage" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
objectData:
  rootCtx: The root context of the chart.
  objectData: The ingress object.
*/}}

{{- define "tc.v1.common.lib.ingress.integration.homepage" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

{{- if $objectData.integrations  $objectData.integrations.homepage $objectData.integrations.homepage.enabled -}}
gethomepage.dev/enabled: "true"
gethomepage.dev/name: {{ $objectData.integrations.homepage.name | default ( camelcase $rootCtx.Chart.Name ) }}
gethomepage.dev/description: {{ $objectData.integrations.homepage.description | default $rootCtx.Chart.Description }}
gethomepage.dev/group: {{ $objectData.integrations.homepage.group | default "default" }}
gethomepage.dev/icon: {{ $objectData.integrations.homepage.icon | default $rootCtx.Chart.Icon }}
{{- if $objectData.integrations.homepage.podSelector -}}
gethomepage.dev/pod-selector: {{ . }}
{{- else -}}
gethomepage.dev/pod-selector: ""
{{- end -}}
{{- with $objectData.integrations.homepage.weight -}}
gethomepage.dev/weight: {{ . }}
{{- end -}}
gethomepage.dev/widget.type: {{ $objectData.integrations.homepage.widget.type | default $rootCtx.Chart.Name }}
{{- with (index $objectData.hosts 0) -}}
gethomepage.dev/widget.url: {{ $objectData.integrations.homepage.widget.url | default (printf "%v%v" .host ( .path | default "/")) }}
{{- end -}}
{{- range $$objectData.integrations.homepage.widget.custom -}}
gethomepage.dev/widget.{{ .name }}: {{ .value }}
{{- end -}}
{{- end -}}
{{- end -}}
