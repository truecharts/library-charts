{{- define "tc.v1.common.lib.webhook.validation" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}

  {{- if not $objectData.type -}}
    {{- fail (printf "Webhook - Expected <type> in <webhook.%v> to not be empty" $objectData.shortName) -}}
  {{- end -}}

  {{- $type := tpl $objectData.type $rootCtx -}}
  {{- $types := (list "validating" "mutating") -}}
  {{- if not (mustHas $type $types) -}}
    {{- fail (printf "Webhook - Expected <type> in <webhook.%v> to be one of [%s], but got [%v]" $objectData.shortName (join ", " $types) $type) -}}
  {{- end -}}

  {{- if not $objectData.webhooks -}}
    {{- fail (printf "Webhook - Expected <webhooks> in <webhook.%v> to not be empty" $objectData.shortName) -}}
  {{- end -}}

  {{- if not (kindIs "slice" $objectData.webhooks) -}}
    {{- fail (printf "Webhook - Expected <webhooks> in <webhook.%v> to be a list, but got [%v]" $objectData.shortName (kindOf $objectData.webhooks)) -}}
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

    {{- if not $webhook.clientConfig -}}
      {{- fail (printf "Webhook - Expected <clientConfig> in <webhook.%v.%v> to not be empty" $objectData.shortName $webhook.name) -}}
    {{- end -}}

    {{- with $webhook.clientConfig -}}
      {{- if and .url .service -}}
        {{- fail (printf "Webhook - Expected either <url> or <service> in <webhook.%v.%v> to be defined, but got both" $objectData.shortName $webhook.name) -}}
      {{- end -}}

      {{- $service := .service -}}

      {{- if $service -}}
        {{- if not $service.name -}}
          {{- fail (printf "Webhook - Expected <service.name> in <webhook.%v.%v> to not be empty" $objectData.shortName $webhook.name) -}}
        {{- end -}}

        {{- if not $service.namespace -}}
          {{- fail (printf "Webhook - Expected <service.namespace> in <webhook.%v.%v> to not be empty" $objectData.shortName $webhook.name) -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}

    {{- if not $webhook.rules -}}
      {{- fail (printf "Webhook - Expected <rules> in <webhook.%v.%v> to not be empty" $objectData.shortName $webhook.name) -}}
    {{- end -}}

    {{- if not (kindIs "slice" $webhook.rules) -}}
      {{- fail (printf "Webhook - Expected <rules> in <webhook.%v.%v> to be a list, but got [%v]" $objectData.shortName $webhook.name (kindOf $webhook.rules)) -}}
    {{- end -}}

    {{- range $rule := $webhook.rules -}}
      {{- if not $rule.apiGroups -}}
        {{- fail (printf "Webhook - Expected <apiGroups> in <webhook.%v.%v> to not be empty" $objectData.shortName $webhook.name) -}}
      {{- end -}}

      {{- if not $rule.apiVersions -}}
        {{- fail (printf "Webhook - Expected <apiVersions> in <webhook.%v.%v> to not be empty" $objectData.shortName $webhook.name) -}}
      {{- end -}}

      {{- if not $rule.operations -}}
        {{- fail (printf "Webhook - Expected <operations> in <webhook.%v.%v> to not be empty" $objectData.shortName $webhook.name) -}}
      {{- end -}}

      {{- if not $rule.resources -}}
        {{- fail (printf "Webhook - Expected <resources> in <webhook.%v.%v> to not be empty" $objectData.shortName $webhook.name) -}}
      {{- end -}}

      {{- $scopes := (list "Cluster" "Namespaced" "*") -}}
      {{- with $rule.scope -}}
        {{- $scope := tpl . $rootCtx -}}
        {{- if not (mustHas $scope $scopes) -}}
          {{- fail (printf "Webhook - Expected <scope> in <webhook.%v.%v> to be one of [%s], but got [%v]" $objectData.shortName $webhook.name (join ", " $scopes) $scope) -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}

    {{- with $webhook.failurePolicy -}}
      {{- $policy := tpl . $rootCtx -}}
      {{- $failPolicies := (list "Ignore" "Fail") -}}
      {{- if not (mustHas $policy $failPolicies) -}}
        {{- fail (printf "Webhook - Expected <failurePolicy> in <webhook.%v.%v> to be one of [%s], but got [%v]" $objectData.shortName $webhook.name (join ", " $failPolicies) $policy) -}}
      {{- end -}}
    {{- end -}}

    {{- with $webhook.matchPolicy -}}
      {{- $policy := tpl . $rootCtx -}}
      {{- $matchPolicies := (list "Exact" "Equivalent") -}}
      {{- if not (mustHas $policy $matchPolicies) -}}
        {{- fail (printf "Webhook - Expected <matchPolicy> in <webhook.%v.%v> to be one of [%s], but got [%v]" $objectData.shortName $webhook.name (join ", " $matchPolicies) $policy) -}}
      {{- end -}}
    {{- end -}}

    {{- if and (eq $type "validating") $webhook.reinvocationPolicy -}}
      {{- fail (printf "Webhook - Expected [mutating] type in <webhook.%v.%v> when <reinvocationPolicy> is defined" $objectData.shortName $webhook.name) -}}
    {{- end -}}

    {{- if and (eq $type "mutating") $webhook.reinvocationPolicy -}}
      {{- $policy := tpl $webhook.reinvocationPolicy $rootCtx -}}
      {{- $reinvPolicies := (list "Never" "IfNeeded") -}}
      {{- if not (mustHas $policy $reinvPolicies) -}}
        {{- fail (printf "Webhook - Expected <reinvocationPolicy> in <webhook.%v.%v> to be one of [%s], but got [%v]" $objectData.shortName $webhook.name (join ", " $reinvPolicies) $webhook.reinvocationPolicy) -}}
      {{- end -}}
    {{- end -}}

    {{- with $webhook.sideEffects -}}
      {{- $effect := tpl . $rootCtx -}}
      {{- $sideEffects := (list "None" "NoneOnDryRun") -}}
      {{- if not (mustHas $effect $sideEffects) -}}
        {{- fail (printf "Webhook - Expected <sideEffects> in <webhook.%v.%v> to be one of [%s], but got [%v]" $objectData.shortName $webhook.name (join ", " $sideEffects) $effect) -}}
      {{- end -}}
    {{- end -}}

    {{- if (hasKey $webhook "timeoutSeconds") -}}
      {{- if (kindIs "invalid" $webhook.timeoutSeconds) -}}
        {{- fail (printf "Webhook - Expected the defined key <timeoutSeconds> in <webhook.%v.%v> to not be empty" $objectData.shortName $webhook.name) -}}
      {{- end -}}

      {{- $timeout := $webhook.timeoutSeconds -}}
      {{- if (kindIs "string" $timeout)  -}}
        {{- $timeout = tpl $webhook.timeoutSeconds $rootCtx -}}
      {{- end -}}

      {{- if not (mustHas (kindOf $timeout) (list "int" "int64" "float64")) -}}
        {{- fail (printf "Webhook - Expected <timeoutSeconds> in <webhook.%v.%v> to be an integer, but got [%v]" $objectData.shortName $webhook.name (kindOf $timeout)) -}}
      {{- end -}}

      {{- if (lt (int $timeout) 1) -}}
        {{- fail (printf "Webhook - Expected <timeoutSeconds> in <webhook.%v.%v> to be greater than 0, but got [%v]" $objectData.shortName $webhook.name $timeout) -}}
      {{- end -}}

      {{- if (gt (int $timeout) 30) -}}
        {{- fail (printf "Webhook - Expected <timeoutSeconds> in <webhook.%v.%v> to be less than 30, but got [%v]" $objectData.shortName $webhook.name $timeout) -}}
      {{- end -}}
    {{- end -}}

  {{- end -}}

{{- end -}}
