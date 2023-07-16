{{- define "tc.v1.common.lib.webhook.validation" -}}
  {{- $objectData := .objectData -}}

  {{- $types := (list "validating" "mutating") -}}
  {{- if not (mustHas $objectData.type $types) -}}
    {{- fail (printf "Webhook - Expected <type> in <webhook.%v> to be one of [%s] but got [%v]" $objectData.shortName (join ", " $types) $objectData.type) -}}
  {{- end -}}

  {{- if not $objectData.webhooks -}}
    {{- fail (printf "Webhook - Expected <webhooks> in <webhook.%v> to be non-empty" $objectData.shortName) -}}
  {{- end -}}
{{- end -}}
