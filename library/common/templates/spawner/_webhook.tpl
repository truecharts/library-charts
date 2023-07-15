{{/* MutatingWebhookConfiguration Spawwner */}}
{{/* Call this template:
{{ include "tc.v1.common.spawner.webhook" $ -}}
*/}}

{{- define "tc.v1.common.spawner.webhook" -}}

  {{- range $name, $mutatingWebhookConfiguration := .Values.webhook -}}

    {{- $enabled := false -}}
    {{- if hasKey $mutatingWebhookConfiguration "enabled" -}}
      {{- if not (kindIs "invalid" $mutatingWebhookConfiguration.enabled) -}}
        {{- $enabled = $mutatingWebhookConfiguration.enabled -}}
      {{- else -}}
        {{- fail (printf "Mutating Webhook Configuration - Expected the defined key [enabled] in <webhook.%s> to not be empty" $name) -}}
      {{- end -}}
    {{- end -}}

    {{- if kindIs "string" $enabled -}}
      {{- $enabled = tpl $enabled $ -}}

      {{/* After tpl it becomes a string, not a bool */}}
      {{-  if eq $enabled "true" -}}
        {{- $enabled = true -}}
      {{- else if eq $enabled "false" -}}
        {{- $enabled = false -}}
      {{- end -}}
    {{- end -}}

    {{- if $enabled -}}

      {{/* Create a copy of the mutatingWebhookConfiguration */}}
      {{- $objectData := (mustDeepCopy $mutatingWebhookConfiguration) -}}

      {{- $objectName := (printf "%s-%s" (include "tc.v1.common.lib.chart.names.fullname" $) $name) -}}
      {{- if hasKey $objectData "expandObjectName" -}}
        {{- if not $objectData.expandObjectName -}}
          {{- $objectName = $name -}}
        {{- end -}}
      {{- end -}}

      {{/* Perform validations */}}
      {{- include "tc.v1.common.lib.chart.names.validation" (dict "name" $objectName) -}}
      {{/* TODO: Implement and add tests */}}
      {{- include "tc.v1.common.lib.webhook.validation" (dict "objectData" $objectData) -}}
      {{- include "tc.v1.common.lib.metadata.validation" (dict "objectData" $objectData "caller" "MutatingWebhookConfiguration") -}}

      {{/* Set the name of the MutatingWebhookConfiguration */}}
      {{- $_ := set $objectData "name" $objectName -}}
      {{- $_ := set $objectData "shortName" $name -}}

      {{/* Call class to create the object */}}
      {{- if eq $objectData.type "validating" -}}
        {{- include "tc.v1.common.class.validatingWebhookconfiguration" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- else if eq $objectData.type "mutating" -}}
        {{- include "tc.v1.common.class.mutatingWebhookConfiguration" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- else -}}
        {{- fail (printf "WebhookConfiguration - Invalid [type] in <webhook.%s> " $name) -}}
      {{- end -}}

    {{- end -}}

  {{- end -}}

{{- end -}}
