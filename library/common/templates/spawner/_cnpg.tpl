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
    {{- $recPrevious := (lookup "v1" "ConfigMap" $.Release.Namespace $fetchname) -}}
    {{- if $recPrevious -}}
      {{- $recValue = (index $recPrevious.data "recoverystring") -}}
    {{- else if $objectData.forceRecovery -}}
      {{- $recValue = randAlphaNum 5 -}}
    {{- end -}}

    {{- if $recValue -}}
      {{- $_ := set $objectData "recValue" $recValue -}}
      {{- $recConfig := include "tc.v1.common.lib.cnpg.configmap.recoverystring" (dict "recoverystring" $recValue) | fromYaml -}}
      {{- $_ := set $.Values.configmap (printf "%s-recoverystring" $objectData.shortName) $recConfig -}}
    {{- end -}}

    {{- if $enabled -}}
      {{- $validModes := (list "standalone" "replica" "recovery") -}}
      {{- if not (mustHas $objectData.mode $validModes) -}}
        {{- fail (printf "CNPG - Expected mode to be one of [%s], but got [%s]" (join ", " $validModes) $objectData.mode) -}}
      {{- end -}}

      {{- if not (hasKey $objectData "cluster") -}}
        {{- fail "CNPG - Expected [cluster] key to exist." -}}
      {{- end -}}

      {{/* If pooler key is no defined, create it so we dont get nil pointers */}}
      {{- if not (hasKey $objectData "pooler") -}}
        {{- $_ := set $objectData "pooler" dict -}}
      {{- end -}}

      {{/* If backups key is no defined, create it so we dont get nil pointers */}}
      {{- if not (hasKey $objectData "backups") -}}
        {{- $_ := set $objectData "backups" (dict "provider" "") -}}
      {{- end -}}

      {{/* If recovery key is no defined, create it so we dont get nil pointers */}}
      {{- if not (hasKey $objectData "recovery") -}}
        {{- $_ := set $objectData "recovery" (dict "method" "") -}}
      {{- end -}}

      {{- if not (hasKey $objectData.recovery "pitrTarget") -}}
        {{- $_ := set $objectData.recovery "pitrTarget" dict -}}
      {{- end -}}

      {{- include "tc.v1.common.class.cnpg.cluster" (dict "rootCtx" $ "objectData" $objectData) -}}

      {{- $_ := set $objectData.pooler "type" "rw" -}}
      {{- include "tc.v1.common.class.cnpg.pooler" (dict "rootCtx" $ "objectData" $objectData) -}}

      {{- if $objectData.pooler.acceptRO -}}
        {{- $_ := set $objectData.pooler "type" "ro" -}}
        {{- include "tc.v1.common.class.cnpg.pooler" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- end -}}
    {{- end -}}

    {{- range $name, $backup := $objectData.backups.manual -}}
      {{/* FIXME: I dont understand this here, we loop over manual backups
      and each time we overwrite the $objectData.backupName etc.
      So at the end backupName will have the name of the last manual backup. */}}
      {{- $_ := set $objectData "backupName" $name -}}
      {{- $_ := set $objectData "backupLabels" $backup.labels -}}
      {{- $_ := set $objectData "backupAnnotations" $backup.annotations -}}
      {{- include "tc.v1.common.class.cnpg.backup" (dict "rootCtx" $ "objectData" $objectData) -}}
    {{- end -}}

    {{- $validProviders := (list "azure" "google" "object_store" "s3") -}}
    {{- if $objectData.backups.enabled -}}
      {{- if not (mustHas $objectData.backups.provider $validProviders) -}}
        {{- fail (printf "CNPG - Expected <backups.provider> to be one of [%s], but got [%s]" (join ", " $validProviders) $objectData.backups.provider) -}}
      {{- end -}}

      {{- if eq $objectData.backups.provider "azure" -}}
        {{- with (include "tc.v1.common.lib.cnpg.secret.azure" (dict "creds" $objectData.backups.azure) | fromYaml) -}}
          {{- $_ := set $.Values.secret (printf "%s-backup-azure-creds" $objectData.shortName) . -}}
        {{- end -}}
      {{- end -}}

      {{- if eq $objectData.backups.provider "google" -}}
        {{- with (include "tc.v1.common.lib.cnpg.secret.google" (dict "creds" $objectData.backups.google) | fromYaml) -}}
          {{- $_ := set $.Values.secret (printf "%s-backup-google-creds" $objectData.shortName) . -}}
        {{- end -}}
      {{- end -}}

      {{- if eq $objectData.backups.provider "s3" -}}
        {{- with (include "tc.v1.common.lib.cnpg.secret.s3" (dict "creds" $objectData.backups.s3) | fromYaml) -}}
          {{- $_ := set $.Values.secret (printf "%s-backup-s3-creds" $objectData.shortName) . -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}

    {{- $validMethods := (list "object_store" "backup" "pg_basebackup") -}}
    {{- if and $objectData.recovery.method (not (mustHas $objectData.recovery.method $validMethods)) -}}
      {{- fail (printf "CNPG - Expected <recovery.method> to be one of [%s], but got [%s]" (join ", " $validMethods) $objectData.recovery.method) -}}
    {{- end -}}

    {{- if and (eq $objectData.mode "recovery") (eq $objectData.recovery.method "object_store") -}}
      {{- if not (mustHas $objectData.recovery.provider $validProviders) -}}
        {{- fail (printf "CNPG - Expected <recovery.provider> to be one of [%s], but got [%s]" (join ", " $validProviders) $objectData.recovery.provider) -}}
      {{- end -}}

      {{- if eq $objectData.recovery.provider "azure" -}}
        {{- with (include "tc.v1.common.lib.cnpg.secret.azure" (dict "creds" $objectData.recovery.azure) | fromYaml) -}}
          {{- $_ := set $.Values.secret (printf "%s-recovery-azure-creds" $objectData.shortName) . -}}
        {{- end -}}
      {{- end -}}

      {{- if eq $objectData.recovery.provider "google" -}}
        {{- with (include "tc.v1.common.lib.cnpg.secret.google" (dict "creds" $objectData.recovery.google) | fromYaml) -}}
          {{- $_ := set $.Values.secret (printf "%s-recovery-google-creds" $objectData.shortName) . -}}
        {{- end -}}
      {{- end -}}

      {{- if eq $objectData.recovery.provider "s3" -}}
        {{- with (include "tc.v1.common.lib.cnpg.secret.s3" (dict "creds" $objectData.recovery.s3) | fromYaml) -}}
          {{- $_ := set $.Values.secret (printf "%s-recovery-s3-creds" $objectData.shortName) . -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}

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

      {{- if $objectData.monitoring -}}
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
{{- end -}}
