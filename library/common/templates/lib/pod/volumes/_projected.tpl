{{/* Returns projected Volume */}}
{{/* Call this template:
{{ include "tc.v1.common.lib.pod.volume.projected" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the volume.
*/}}
{{- define "tc.v1.common.lib.pod.volume.projected" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- if not $objectData.sources -}}
    {{- fail "Persistence - Expected non-empty [sources] on [projected] type" -}}
  {{- end -}}

  {{- $defMode := "" -}}
  {{- if (and $objectData.defaultMode (not (kindIs "string" $objectData.defaultMode))) -}}
    {{- fail (printf "Persistence - Expected [defaultMode] to be [string], but got [%s]" (kindOf $objectData.defaultMode)) -}}
  {{- end -}}

  {{- with $objectData.defaultMode -}}
    {{- $defMode = tpl $objectData.defaultMode $rootCtx -}}
  {{- end -}}

  {{- if and $defMode (not (mustRegexMatch "^[0-9]{4}$" $defMode)) -}}
    {{- fail (printf "Persistence - Expected [defaultMode] to have be in format of [\"0777\"], but got [%q]" $defMode) -}}
  {{- end -}}
  {{- $allowedSources := (list "clusterTrustBundle" "configMap" "downwardAPI" "secret" "serviceAccountToken") }}
- name: {{ $objectData.shortName }}
  projected:
    {{- with $defMode }}
    defaultMode: {{ . }}
    {{- end }}
    sources:
    {{- range $source := $objectData.sources -}}
      {{- if gt ($source | keys | len) 1 -}}
        {{- fail "Persistence - Expected only one source type per item in [projected] volume" -}}
      {{- end -}}

      {{- $k := $source | keys | first -}}
      {{- $v := (get $source $k) -}}

      {{- if eq $k "serviceAccountToken" }}
        {{- include "tc.v1.common.lib.pod.volume.projected.serviceAccountToken" (dict "rootCtx" $rootCtx "source" $v) | nindent 6 }}
      {{- else if eq $k "secret" }}
        {{- include "tc.v1.common.lib.pod.volume.projected.secret" (dict "rootCtx" $rootCtx "source" $v) | nindent 6 }}
      {{- else if eq $k "configMap" }}
        {{- include "tc.v1.common.lib.pod.volume.projected.configMap" (dict "rootCtx" $rootCtx "source" $v) | nindent 6 }}
      {{- else if eq $k "downwardAPI" }}
        {{- include "tc.v1.common.lib.pod.volume.projected.downwardAPI" (dict "rootCtx" $rootCtx "source" $v) | nindent 6 }}
      {{- else if eq $k "clusterTrustBundle" }}
        {{- include "tc.v1.common.lib.pod.volume.projected.clusterTrustBundle" (dict "rootCtx" $rootCtx "source" $v) | nindent 6 }}
      {{- else -}}
        {{- fail (printf "Persistence - Invalid source type [%s] for projected. Valid sources are [%s]" $k (join ", " $allowedSources)) -}}
      {{- end -}}
    {{- end -}}
{{- end -}}

{{- define "tc.v1.common.lib.pod.volume.projected.serviceAccountToken" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $source := .source -}}

  {{- if hasKey $source "expirationSeconds" -}}
    {{- if lt ($source.expirationSeconds | int) 600 -}}
      {{- fail (printf "Persistence - Expected [expirationSeconds] to be greater than 600 seconds, but got [%v]" $source.expirationSeconds) -}}
    {{- end -}}
  {{- end -}}

  {{- if not $source.path -}}
    {{- fail "Persistence - Expected non-empty [path] on [serviceAccountToken] type" -}}
  {{- end -}}
- serviceAccountToken:
  {{- with $source.audience }}
    audience: {{ tpl . $rootCtx }}
  {{- end -}}
  {{- with $source.expirationSeconds }}
    expirationSeconds: {{ . }}
  {{- end }}
    path: {{ tpl $source.path $rootCtx }}
{{- end -}}

{{- define "tc.v1.common.lib.pod.volume.projected.secret" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $source := .source -}}

{{- end -}}

{{- define "tc.v1.common.lib.pod.volume.projected.configMap" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $source := .source -}}

{{- end -}}

{{- define "tc.v1.common.lib.pod.volume.projected.downwardAPI" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $source := .source -}}

{{- end -}}

{{- define "tc.v1.common.lib.pod.volume.projected.clusterTrustBundle" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $source := .source -}}

{{- end -}}
