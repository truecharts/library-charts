{{- define "tc.v1.common.lib.webhook.validation" -}}
  {{- $objectData := .objectData -}}

  {{- $types := (list "validating" "mutating") -}}
  {{- if not (mustHas $objectData.type $types) -}}
    {{- fail (printf "Webhook - Expected <type> in <webhook.%v> to be one of [%s], but got [%v]" $objectData.shortName (join ", " $types) $objectData.type) -}}
  {{- end -}}

  {{- if not $objectData.webhooks -}}
    {{- fail (printf "Webhook - Expected <webhooks> in <webhook.%v> to not be empty" $objectData.shortName) -}}
  {{- end -}}

  {{- range $webhook := $objectData.webhooks -}}
    {{- if not $webhook.name -}}
      {{- fail (printf "Webhook - Expected <name> in <webhook.%v> to not be empty" $objectData.shortName) -}}
    {{- end -}}

    {{- if not $webhook.admissionReviewVersions -}}
      {{- fail (printf "Webhook - Expected <admissionReviewVersions> in <webhook.%v.%v> to not be empty" $objectData.shortName $webhook.name) -}}
    {{- end -}}

    {{- range $adm := $webhook.admissionReviewVersions -}}
      {{- if not (kindIs "string" $adm) -}}
        {{- fail (printf "Webhook - Expected <admissionReviewVersions> in <webhook.%v.%v> to be a string" $objectData.shortName $webhook.name) -}}
      {{- end -}}
    {{- end -}}

    {{/*TODO: clientConfig */}}
    {{- if not $webhook.clientConfig -}}
      {{- fail (printf "Webhook - Expected <clientConfig> in <webhook.%v.%v> to not be empty" $objectData.shortName $webhook.name) -}}
    {{- end -}}

    {{/*TODO: rules */}}

    {{- with $webhook.failurePolicy -}}
      {{- $failPolicies := (list "Ignore" "Fail") -}}
      {{- if not (mustHas . $failPolicies) -}}
        {{- fail (printf "Webhook - Expected <failurePolicy> in <webhook.%v.%v> to be one of [%s], but got [%v]" $objectData.shortName $webhook.name (join ", " $failPolicies) .) -}}
      {{- end -}}
    {{- end -}}

    {{- with $webhook.matchPolicy -}}
      {{- $matchPolicies := (list "Exact" "Equivalent") -}}
      {{- if not (mustHas . $matchPolicies) -}}
        {{- fail (printf "Webhook - Expected <matchPolicy> in <webhook.%v.%v> to be one of [%s], but got [%v]" $objectData.shortName $webhook.name (join ", " $matchPolicies) .) -}}
      {{- end -}}
    {{- end -}}

    {{- if and (eq $objectData.type "validating") $webhook.reinvocationPolicy -}}
      {{- fail (printf "Webhook - Expected [mutating] type in <webhook.%v.%v> when <reinvocationPolicy> is defined" $objectData.shortName $webhook.name) -}}
    {{- end -}}

    {{- if and (eq $objectData.type "mutating") $webhook.reinvocationPolicy -}}
      {{- $reinvPolicies := (list "Never" "IfNeeded") -}}
      {{- if not (mustHas . $reinvPolicies) -}}
        {{- fail (printf "Webhook - Expected <reinvocationPolicy> in <webhook.%v.%v> to be one of [%s], but got [%v]" $objectData.shortName $webhook.name (join ", " $reinvPolicies) $webhook.reinvocationPolicy) -}}
      {{- end -}}
    {{- end -}}

    {{- with $webhook.sideEffects -}}
      {{- $sideEffects := (list "None" "NoneOnDryRun") -}}
      {{- if not (mustHas . $sideEffects) -}}
        {{- fail (printf "Webhook - Expected <sideEffects> in <webhook.%v.%v> to be one of [%s], but got [%v]" $objectData.shortName $webhook.name (join ", " $sideEffects) .) -}}
      {{- end -}}
    {{- end -}}

    {{- if (hasKey $webhook "timeoutSeconds") -}}
      {{- if (kindIs "invalid" $webhook.timeoutSeconds) -}}
        {{- fail (printf "Webhook - Expected the defined key <timeoutSeconds> in <webhook.%v.%v> to not be empty" $objectData.shortName $webhook.name) -}}
      {{- end -}}

      {{- if not (mustHas (kindOf $webhook.timeoutSeconds) (list "int" "int64" "float64")) -}}
        {{- fail (printf "Webhook - Expected <timeoutSeconds> in <webhook.%v.%v> to be an integer, but got [%v]" $objectData.shortName $webhook.name (kindOf $webhook.timeoutSeconds)) -}}
      {{- end -}}

      {{- if (lt (int $webhook.timeoutSeconds) 1) -}}
        {{- fail (printf "Webhook - Expected <timeoutSeconds> in <webhook.%v.%v> to be greater than 0, but got [%v]" $objectData.shortName $webhook.name $webhook.timeoutSeconds) -}}
      {{- end -}}

      {{- if (gt (int $webhook.timeoutSeconds) 30) -}}
        {{- fail (printf "Webhook - Expected <timeoutSeconds> in <webhook.%v.%v> to be less than 30, but got [%v]" $objectData.shortName $webhook.name $webhook.timeoutSeconds) -}}
      {{- end -}}
    {{- end -}}

  {{- end -}}

{{- end -}}
