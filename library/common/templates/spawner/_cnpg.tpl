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
        {{- fail (printf "cnpg - Expected the defined key [enabled] in <cnpg.%s> to not be empty" $name) -}}
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
    {{- with (lookup "v1" "ConfigMap" .Release.Namespace $fetchname) -}}
      {{- $recValue = (index .data "recoverystring") -}}
    {{- else if $objectData.forceRecovery -}}
      {{- $recValue = randAlphaNum 5 -}}
    {{- end -}}

    {{- if $recValue -}}
      {{- $_ := set $objectData "recValue" $recValue -}}
      {{- $recConfig := include "tc.v1.common.lib.cnpg.configmap.recoverystring" (dict "recoverystring" $recValue) | fromYaml -}}
      {{- $_ := set $.Values.configmap (printf "%s-recoverystring" $objectData.shortName) $recConfig -}}
    {{- end -}}

    {{- if $enabled -}}
      # TODO: Pass the correct data to ALL includes as we not create a "deep copy" of the object
      {{- include "tc.v1.common.class.cnpg.cluster" $ -}}

      {{- $_ := set $objectData.pooler "type" "rw" -}}
      {{- if not $objectData.pooler.acceptRO -}}
        {{- include "tc.v1.common.class.cnpg.pooler" $ -}}
      {{- else -}}
        {{- include "tc.v1.common.class.cnpg.pooler" $ -}}
        {{- $_ := set $objectData.pooler "type" "ro" -}}
        {{- include "tc.v1.common.class.cnpg.pooler" $ -}}
      {{- end -}}
    {{- end -}}

    {{- range $name, $backup := $objectData.backups.manual -}}
      {{- $_ := set $objectData "backupName" $name -}}
      {{- $_ := set $objectData "backupLabels" $backup.labels -}}
      {{- $_ := set $objectData "backupAnnotations" $backup.annotations -}}
      {{- include "tc.v1.common.class.cnpg.backup" $ -}}
    {{- end -}}

    {{- $validProviders := (list "azure" "google" "object_store" "s3") -}}


    {{- if $objectData.backups.enabled -}}
      {{- if not (mustHas $objectData.backups.provider $validProviders) -}}
        {{- fail (printf "CNPG - Expected <backups.provider> to be one of [%s], but got [%s]", (join "," $validProviders) $objectData.backaups.provider) -}}
      {{- end -}}

      {{- if eq $cnpgValues.backups.provider "azure" -}}
        {{- with (include "tc.v1.common.lib.cnpg.secret.azure" (dict "creds" $objectData.backups.azure) | fromYaml) -}}
          {{- $_ := set $.Values.secret (printf "%s-backup-azure-creds" $objectData.shortName) . -}}
      {{- end -}}

      {{- if eq $cnpgValues.backups.provider "google" -}}
        {{- with (include "tc.v1.common.lib.cnpg.secret.google" (dict "creds" $objectData.backups.google) | fromYaml) -}}
          {{- $_ := set $.Values.secret (printf "%s-backup-google-creds" $objectData.shortName) . -}}
        {{- end -}}
      {{- end -}}

      {{- if eq $cnpgValues.backups.provider "s3" -}}
        {{- with (include "tc.v1.common.lib.cnpg.secret.s3" (dict "creds" $objectData.backups.s3) | fromYaml) -}}
          {{- $_ := set $.Values.secret (printf "%s-backup-s3-creds" $objectData.shortName) . -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}

    {{- if and (eq $objectData.mode "recovery") (eq $objectData.recovery.method "obect_store") -}}
      {{- if not (mustHas $objectData.recovery.provider $validProviders) -}}
        {{- fail (printf "CNPG - Expected <recovery.provider> to be one of [%s], but got [%s]", (join "," $validProviders) $objectData.recovery.provider) -}}
      {{- end -}}

      {{- if eq $objectData.recovery.provider "azure" -}}
        {{- with (include "tc.v1.common.lib.cnpg.secret.azure" (dict "creds" $objectData.recovery.azure) | fromYaml) -}}
          {{- $_ := set $.Values.secret (printf "%s-recovery-azure-creds" $objectData.shortName) . -}}
        {{- end -}}
      {{- end -}}

      {{- if eq $cnpgValues.recovery.provider "google" -}}
        {{- with (include "tc.v1.common.lib.cnpg.secret.google" (dict "creds" $objectData.recovery.google) | fromYaml) -}}
          {{- $_ := set $.Values.secret (printf "%s-recovery-google-creds" $objectData.shortName) . -}}
        {{- end -}}
      {{- end -}}

      {{- if eq $cnpgValues.recovery.provider "s3" -}}
        {{- with (include "tc.v1.common.lib.cnpg.secret.s3" (dict "creds" $cnpgValues.recovery.s3) | fromYaml) -}}
          {{- $_ := set $.Values.secret (printf "%s-recovery-s3-creds" $cnpgValues.shortName) . -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}

    # FIXME: --> checkpoint <--
    {{- $dbPass := "" -}}
    {{- $dbprevious := lookup "v1" "Secret" $.Release.Namespace (printf "%s-user" $cnpgValues.name) -}}
    {{- if or $enabled $dbprevious -}}
      {{/* Inject the required secrets */}}

      {{- if $dbprevious -}}
        {{- $dbPass = (index $dbprevious.data "password") | b64dec -}}
      {{- else -}}
        {{- $dbPass = $cnpgValues.password | default (randAlphaNum 62) -}}
      {{- end -}}

      {{- $std := ((printf "postgresql://%v:%v@%v-rw:5432/%v" $cnpgValues.user $dbPass $cnpgValues.name $cnpgValues.database) | quote) -}}
      {{- $nossl := ((printf "postgresql://%v:%v@%v-rw:5432/%v?sslmode=disable" $cnpgValues.user $dbPass $cnpgValues.name $cnpgValues.database) | quote) -}}
      {{- $porthost := ((printf "%s-rw:5432" $cnpgValues.name) | quote) -}}
      {{- $host := ((printf "%s-rw" $cnpgValues.name) | quote) -}}
      {{- $jdbc := ((printf "jdbc:postgresql://%v-rw:5432/%v" $cnpgValues.name $cnpgValues.database) | quote) -}}

      {{- $userSecret := include "tc.v1.common.lib.cnpg.secret.user" (dict "values" $cnpgValues "dbPass" $dbPass) | fromYaml -}}
      {{- if $userSecret -}}
        {{- $_ := set $.Values.secret (printf "cnpg-%s-user" $cnpgValues.shortName) $userSecret -}}
      {{- end -}}

      {{- $urlSecret := include "tc.v1.common.lib.cnpg.secret.urls" (dict "std" $std "nossl" $nossl "porthost" $porthost "host" $host "jdbc" $jdbc) | fromYaml -}}
      {{- if $urlSecret -}}
        {{- $_ := set $.Values.secret (printf "cnpg-%s-urls" $cnpgValues.shortName) $urlSecret -}}
      {{- end -}}

      {{- $_ := set $cnpgValues.creds "password" ($dbPass | quote) -}}
      {{- $_ := set $cnpgValues.creds "std" $std -}}
      {{- $_ := set $cnpgValues.creds "nossl" $nossl -}}
      {{- $_ := set $cnpgValues.creds "porthost" $porthost -}}
      {{- $_ := set $cnpgValues.creds "host" $host -}}
      {{- $_ := set $cnpgValues.creds "jdbc" $jdbc -}}

      {{- if $cnpgValues.monitoring -}}
        {{- if $cnpgValues.monitoring.enablePodMonitor -}}
          {{- $poolermetrics :=  include "tc.v1.common.lib.cnpg.metrics.pooler" (dict "poolerName" (printf "%s-rw" $cnpgValues.name)) | fromYaml -}}

          {{- $_ := set $.Values.metrics (printf "cnpg-%s-rw" $cnpgValues.shortName) $poolermetrics -}}
          {{- if $cnpgValues.pooler.acceptRO -}}
            {{- $poolermetricsRO :=  include "tc.v1.common.lib.cnpg.metrics.pooler" (dict "poolerName" (printf "%s-ro" $cnpgValues.name)) | fromYaml -}}
            {{- $_ := set $.Values.metrics (printf "cnpg-%s-ro" $cnpgValues.shortName) $poolermetricsRO -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}

    {{- end -}}
  {{- end -}}
{{- end -}}
