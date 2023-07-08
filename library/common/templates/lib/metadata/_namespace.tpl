{{- define "tc.v1.common.lib.metadata.namespace" -}}
  {{- $caller := .caller -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}

  {{- $namespace := $rootCtx.Release.Namespace -}}
  {{- if $objectData.namespace -}}
    {{- $namespace = tpl $objectData.namespace $rootCtx -}}
  {{- end -}}

  {{- if not (mustRegexMatch "^[a-z0-9]([a-z0-9]-?|-?[a-z0-9]){0,61}[a-z0-9]$" $namespace) -}}
    {{- fail (printf "%s - Namespace [%s] is not valid. Must start and end with an alphanumeric lowercase character. It can contain '-'. And must be at most 63 characters." $caller $namespace) -}}
  {{- end -}}

  {{- $namespace -}}

{{- end -}}
