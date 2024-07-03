{{/* RBAC Primary Validation */}}
{{/* Call this template:
{{ include "tc.v1.common.lib.rbac.primaryValidation" $ -}}
*/}}

{{- define "tc.v1.common.lib.rbac.primaryValidation" -}}
  {{- $result := include "tc.v1.common.lib.rbac.hasPrimaryOnEnabled" (dict "rootCtx" $) | fromJson -}}
  {{- if $result.hasMoreThanOne -}}
    {{- fail "RBAC - Only one rbac can be primary" -}}
  {{- end -}}

  {{/* Require at least one primary rbac, if any enabled */}}
  {{- if and $result.hasEnabled (not $result.hasPrimary) -}}
    {{- fail "RBAC - At least one enabled rbac must be primary" -}}
  {{- end -}}

{{- end -}}

{{- define "tc.v1.common.lib.rbac.hasPrimaryOnEnabled" -}}
  {{- $rootCtx := .rootCtx -}}

  {{/* Initialize values */}}
  {{- $hasPrimary := false -}}
  {{- $hasMoreThanOne := false -}}
  {{- $hasEnabled := false -}}

  {{- range $name, $rbac := $rootCtx.Values.rbac -}}
    {{- $enabled := (include "tc.v1.common.lib.util.enabled" (dict
          "rootCtx" $rootCtx "objectData" $rbac
          "name" $name "caller" "RBAC" "key" "rbac"
    )) -}}
    {{/* If rbac is enabled */}}
    {{- if eq $enabled "true" -}}
      {{- $hasEnabled = true -}}

      {{/* And rbac is primary */}}
      {{- if and (hasKey $rbac "primary") ($rbac.primary) -}}

        {{/* Fail if there is already a primary rbac */}}
        {{- if $hasPrimary -}}
          {{- $hasMoreThanOne = true -}}
        {{- end -}}

        {{- $hasPrimary = true -}}

      {{- end -}}

    {{- end -}}
  {{- end -}}

  {{- dict "hasEnabled" $hasEnabled "hasPrimary" $hasPrimary "hasMoreThanOne" $hasMoreThanOne | toJson }}
{{- end -}}
