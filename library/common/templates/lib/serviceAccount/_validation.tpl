{{/* Service Account Primary Validation */}}
{{/* Call this template:
{{ include "tc.v1.common.lib.serviceAccount.primaryValidation" $ -}}
*/}}

{{- define "tc.v1.common.lib.serviceAccount.primaryValidation" -}}
  {{- $result := include "tc.v1.common.lib.serviceAccount.hasPrimaryOnEnabled" (dict "rootCtx" $) | fromJson -}}
  {{- if $result.hasMoreThanOne -}}
    {{- fail "Service Account - Only one service account can be primary" -}}
  {{- end -}}

  {{/* Require at least one primary service account, if any enabled */}}
  {{- if and $result.hasEnabled (not $result.hasPrimary) -}}
    {{- fail "Service Account - At least one enabled service account must be primary" -}}
  {{- end -}}

{{- end -}}

{{- define "tc.v1.common.lib.serviceAccount.hasPrimaryOnEnabled" -}}
  {{- $rootCtx := .rootCtx -}}

  {{/* Initialize values */}}
  {{- $hasPrimary := false -}}
  {{- $hasMoreThanOne := false -}}
  {{- $hasEnabled := false -}}

  {{- range $name, $serviceAccount := $rootCtx.Values.serviceAccount -}}
    {{- $enabled := (include "tc.v1.common.lib.util.enabled" (dict
          "rootCtx" $rootCtx "objectData" $serviceAccount
          "name" $name "caller" "Service Account" "key" "serviceAccount"
    )) -}}
    {{/* If service account is enabled */}}
    {{- if eq $enabled "true" -}}
      {{- $hasEnabled = true -}}

      {{/* And service account is primary */}}
      {{- if and (hasKey $serviceAccount "primary") ($serviceAccount.primary) -}}

        {{/* Fail if there is already a primary service account */}}
        {{- if $hasPrimary -}}
          {{- $hasMoreThanOne = true -}}
        {{- end -}}

        {{- $hasPrimary = true -}}

      {{- end -}}

    {{- end -}}
  {{- end -}}

  {{ dict "hasEnabled" $hasEnabled "hasPrimary" $hasPrimary "hasMoreThanOne" $hasMoreThanOne | toJson }}
{{- end -}}
