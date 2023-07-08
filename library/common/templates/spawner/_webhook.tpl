{{/* MutatingWebhookConfiguration Spawwner */}}
{{/* Call this template:
{{ include "tc.v1.common.spawner.webhook" $ -}}
*/}}

{{- define "tc.v1.common.spawner.webhook" -}}

  {{- range $name, $MutatingWebhookConfiguration := .Values.webhooks -}}

    {{- $enabled := false -}}
    {{- if hasKey $MutatingWebhookConfiguration "enabled" -}}
      {{- if not (kindIs "invalid" $MutatingWebhookConfiguration.enabled) -}}
        {{- $enabled = $MutatingWebhookConfiguration.enabled -}}
      {{- else -}}
        {{- fail (printf "MutatingWebhookConfiguration - Expected the defined key [enabled] in <MutatingWebhookConfiguration.%s> to not be empty" $name) -}}
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

      {{/* Create a copy of the MutatingWebhookConfiguration */}}
      {{- $objectData := (mustDeepCopy $MutatingWebhookConfiguration) -}}

      {{- $objectName := (printf "%s-%s" (include "tc.v1.common.lib.chart.names.fullname" $) $name) -}}
      {{- if hasKey $objectData "expandObjectName" -}}
        {{- if not $objectData.expandObjectName -}}
          {{- $objectName = $name -}}
        {{- end -}}
      {{- end -}}

      {{/* Perform validations */}}
      {{- include "tc.v1.common.lib.chart.names.validation" (dict "name" $objectName) -}}
      {{- include "tc.v1.common.lib.mutatingwebhookconfiguration.validation" (dict "objectData" $objectData) -}}
      {{- include "tc.v1.common.lib.metadata.validation" (dict "objectData" $objectData "caller" "MutatingWebhookConfiguration") -}}

      {{/* Set the name of the MutatingWebhookConfiguration */}}
      {{- $_ := set $objectData "name" $objectName -}}
      {{- $_ := set $objectData "shortName" $name -}}

      {{/* Call class to create the object */}}
      {{- if eq $objectdata.type "validating" -}}
        {{- include "tc.v1.common.class.validatingwebhookconfiguration" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- else if eq $objectdata.type "mutating" -}}
        {{- include "tc.v1.common.class.mutatingwebhookconfiguration" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- else -}}
        {{- fail (printf "WebhookConfiguration - Invalid [type] in <webhook.%s> " $name) -}}
      {{- end -}}

    {{- end -}}

  {{- end -}}

{{- end -}}
