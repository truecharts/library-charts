{{/* Renders the cnpg objects required by the chart */}}
{{- define "tc.v1.common.spawner.cnpg" -}}

  {{- $fullname := include "tc.v1.common.lib.chart.names.fullname" $ -}}

  {{/* Generate named cnpges as required */}}
  {{- range $name, $cnpg := $.Values.cnpg -}}

    {{- $enabled := false -}}
    {{- if hasKey $cnpg "enabled" -}}
      {{- if not (kindIs "invalid" $cnpg.enabled) -}}
        {{- $enabled = $cnpg.enabled -}}
      {{- else -}}
        {{- fail (printf "CNPG - Expected the defined key [enabled] in <cnpg.%s> to not be empty" $name) -}}
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

    {{/* Handle forceRecovery string */}}
    {{/* Initialize variables */}}
    {{- $fetchname := printf "%s-recoverystring" $objectName -}}
    {{- $recValue := "" -}}

    {{/* If there are previous configmap, fetch value */}}
    {{- with (lookup "v1" "ConfigMap" $.Release.Namespace $fetchname) -}}
      {{- $recValue = (index .data "recoverystring") -}}
    {{- end -}}

    {{- if $objectData.forceRecovery -}}
      {{- $recValue = randAlphaNum 5 -}}
    {{- end -}}

    {{- if $recValue -}}
      {{- $_ := set $objectData "recValue" $recValue -}}
      {{- $recConfig := include "tc.v1.common.lib.cnpg.configmap.recoverystring" (dict "recoverystring" $recValue) | fromYaml -}}
      {{- $_ := set $.Values.configmap (printf "%s-recoverystring" $objectData.shortName) $recConfig -}}
    {{- end -}}

    {{- if $enabled -}}
      {{/* Sets some default values if none given */}}
      {{- include "tc.v1.common.lib.cnpg.setDefaultKeys" (dict "objectData" $objectData) -}}

      {{/* Validate the object */}}
      {{- include "tc.v1.common.lib.cnpg.validation" (dict "objectData" $objectData) -}}
      {{/* Validate backup here as it used in Cluster too */}}
      {{- include "tc.v1.common.lib.cnpg.cluster.backup.validation" (dict "objectData" $objectData) -}}

      {{/* Create the Cluster object */}}
      {{- include "tc.v1.common.class.cnpg.cluster" (dict "rootCtx" $ "objectData" $objectData) -}}

      {{- if not (hasKey $objectData "pooler") -}} {{/* No required values from user */}}
        {{- $_ := set $objectData "pooler" dict -}}
      {{- end -}}

      {{- $_ := set $objectData.pooler "type" "rw" -}}
      {{- include "tc.v1.common.lib.cnpg.pooler.validation" (dict "objectData" $objectData) -}}
      {{/* Create the RW Pooler object  */}}
      {{- include "tc.v1.common.class.cnpg.pooler" (dict "rootCtx" $ "objectData" $objectData) -}}

      {{- if $objectData.pooler.acceptRO -}}
        {{- $_ := set $objectData.pooler "type" "ro" -}}
        {{/* Create the RO Pooler object  */}}
        {{- include "tc.v1.common.lib.cnpg.pooler.validation" ("objectData" $objectData) -}}
        {{- include "tc.v1.common.class.cnpg.pooler" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- end -}}
    {{- end -}}

    {{- range $name, $backup := $objectData.backups.manual -}}
      {{- $_ := set $objectData "backupName" $name -}}
      {{- $_ := set $objectData "backupLabels" $backup.labels -}}
      {{- $_ := set $objectData "backupAnnotations" $backup.annotations -}}
      {{- include "tc.v1.common.class.cnpg.backup" (dict "rootCtx" $ "objectData" $objectData) -}}
    {{- end -}}

    {{- if $objectData.backups.enabled -}}
      {{- include "tc.v1.common.lib.cnpg.spawner.backup" (dict "objectData" $objectData "rootCtx" $) -}}
    {{- end -}}

    {{- include "tc.v1.common.lib.cnpg.spawner.recovery.objectStore" (dict "objectData" $objectData "rootCtx" $) -}}

    {{- $dbPass := "" -}}
    {{- with (lookup "v1" "Secret" $.Release.Namespace (printf "%s-user" $objectData.name)) -}}
      {{- $dbPass = (index .data "password") | b64dec -}}
    {{- end -}}

    {{- if or $enabled $dbPass -}}

      {{- if not $dbPass -}}
        {{- $dbPass = $objectData.password | default (randAlphaNum 62) -}}
      {{- end -}}

      {{/* Inject the required secrets */}}
      {{- $creds := dict -}}
      {{- $_ := set $creds "std" ((printf "postgresql://%v:%v@%v-rw:5432/%v" $objectData.user $dbPass $objectData.name $objectData.database) | quote) -}}
      {{- $_ := set $creds "nossl" ((printf "postgresql://%v:%v@%v-rw:5432/%v?sslmode=disable" $objectData.user $dbPass $objectData.name $objectData.database) | quote) -}}
      {{- $_ := set $creds "porthost" ((printf "%s-rw:5432" $objectData.name) | quote) -}}
      {{- $_ := set $creds "host" ((printf "%s-rw" $objectData.name) | quote) -}}
      {{- $_ := set $creds "jdbc" ((printf "jdbc:postgresql://%v-rw:5432/%v" $objectData.name $objectData.database) | quote) -}}

      {{- with (include "tc.v1.common.lib.cnpg.secret.user" (dict "values" $objectData "dbPass" $dbPass) | fromYaml) -}}
        {{- $_ := set $.Values.secret (printf "cnpg-%s-user" $objectData.shortName) . -}}
      {{- end -}}

      {{- with (include "tc.v1.common.lib.cnpg.secret.urls" (dict "creds" $creds) | fromYaml) -}}
        {{- $_ := set $.Values.secret (printf "cnpg-%s-urls" $objectData.shortName) . -}}
      {{- end -}}

      {{- if not (hasKey $cnpg "creds") -}}
        {{- $_ := set $cnpg "creds" dict -}}
      {{- end -}}

      {{/* We need to mutate the actual (cnpg) values here not the copy */}}
      {{- $_ := set $cnpg.creds "password" ($dbPass | quote) -}}
      {{- $_ := set $cnpg.creds "std" $creds.std -}}
      {{- $_ := set $cnpg.creds "nossl" $creds.nossl -}}
      {{- $_ := set $cnpg.creds "porthost" $creds.porthost -}}
      {{- $_ := set $cnpg.creds "host" $creds.host -}}
      {{- $_ := set $cnpg.creds "jdbc" $creds.jdbc -}}

      {{- if $objectData.monitoring.enablePodMonitor -}}

        {{- $poolerMetrics := include "tc.v1.common.lib.cnpg.metrics.pooler" (dict "poolerName" (printf "%s-rw" $objectData.name)) | fromYaml -}}
        {{- $_ := set $.Values.metrics (printf "cnpg-%s-rw" $objectData.shortName) $poolerMetrics -}}

        {{- if $objectData.pooler.acceptRO -}}
          {{- $poolerMetricsRO := include "tc.v1.common.lib.cnpg.metrics.pooler" (dict "poolerName" (printf "%s-ro" $objectData.name)) | fromYaml -}}
          {{- $_ := set $.Values.metrics (printf "cnpg-%s-ro" $objectData.shortName) $poolerMetricsRO -}}
        {{- end -}}

      {{- end -}}

    {{- end -}}
  {{- end -}}
{{- end -}}
