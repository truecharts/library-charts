{{/* Renders the cnpg objects required by the chart */}}
{{- define "tc.v1.common.spawner.cnpg" -}}

  {{- $fullname := include "tc.v1.common.lib.chart.names.fullname" $ -}}

  {{- range $name, $cnpg := $.Values.cnpg -}}

    {{- $enabled := false -}}
    {{- if hasKey $cnpg "enabled" -}}
      {{- if not (kindIs "invalid" $cnpg.enabled) -}}
        {{- $enabled = $cnpg.enabled -}}
      {{- else -}}
        {{- fail (printf "CNPG - Expected the defined key [enabled] in [cnpg.%s] to not be empty" $name) -}}
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

    {{/* Create a copy */}}
    {{- $objectData := mustDeepCopy $cnpg -}}
    {{- $objectName := printf "%s-cnpg-%s" $fullname $name -}}

    {{/* Set the name */}}
    {{- $_ := set $objectData "name" $objectName -}}
    {{/* Short name is the one that defined on the chart*/}}
    {{- $_ := set $objectData "shortName" $name -}}
    {{/* Set the cluster name */}}
    {{- $_ := set $objectData "clusterName" (include "tc.v1.common.lib.cnpg.clusterName" (dict "objectData" $objectData)) -}}

    {{- if $enabled -}}

      {{/* Handle Backups/ScheduledBackups */}}
      {{- if and (hasKey $objectData "backups") $objectData.backups.enabled -}}
        {{/* Create secret for backup store */}}
          {{/* TODO: */}}

        {{/* Create Backups */}}
        {{- include "tc.v1.common.lib.cnpg.spawner.backups" (dict "rootCtx" $ "objectData" $objectData) -}}

        {{/* Create ScheduledBackups */}}
        {{- include "tc.v1.common.lib.cnpg.spawner.scheduledBackups" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- end -}}

      {{/* Handle Pooler(s) */}}
      {{- include "tc.v1.common.lib.cnpg.spawner.pooler" (dict "rootCtx" $ "objectData" $objectData) -}}

      {{/* Handle Cluster */}}
      {{- include "tc.v1.common.lib.cnpg.cluster.validation" (dict "objectData" $objectData) -}}
    {{- end -}}

    {{/* Fetch db pass from Secret */}}
    {{- $dbPass := "" -}}
    {{- with (lookup "v1" "Secret" $.Release.Namespace (printf "%s-user" $objectData.name)) -}}
      {{- $dbPass = (index .data "password") | b64dec -}}
    {{- end -}}

    {{/* Either enebled or if there was a dbpass fetched. Required to keep the generated password around */}}
    {{- if or $enabled $dbPass -}}
      {{/* If enabled or dbPass fetched from secret, recreate the secret */}}
      {{- if not $dbPass -}}
        {{/* Use provided password or fallback to generating new password */}}
        {{- $dbPass = $objectData.password | default (randAlphaNum 62) -}}
      {{- end -}}
      {{/* Set password back to password field */}}
      {{- $_ := set $objectData "password" $dbPass -}}

      {{/* Handle DB Credentials Secret, will also inject creds to cnpg.creds */}}
      {{- include "tc.v1.common.lib.cnpg.secrets" (dict "rootCtx" $ "cnpg" $cnpg "objectData" $objectData) -}}
    {{- end -}}

  {{- end -}}
{{- end -}}
