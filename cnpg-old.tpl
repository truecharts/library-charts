{{/* Renders the cnpg objects required by the chart */}}
{{- define "tc.v1.common.spawner.cnpg-old" -}}

  {{/* Generate named cnpges as required */}}
  {{- range $name, $cnpg := $.Values.cnpg -}}

    {{/* Handle forceRecovery string */}}
    {{/* Initialize variables */}}
    {{- $recoveryBaseKey := "recoverystring" -}} {{/* This key is used in both CM name and the key field */}}
    {{- $cmName := printf "%s-%s" $objectName $recoveryBaseKey -}}
    {{- $recoveryValue := "" -}}

    {{/* If there are previous configmap, fetch value */}}
    {{- with (lookup "v1" "ConfigMap" $.Release.Namespace $cmName) -}}
      {{- $recoveryValue = (index .data $recoveryBaseKey) -}}
    {{- end -}}

    {{- if $objectData.forceRecovery -}}
      {{- $recoveryValue = randAlphaNum 5 -}}
    {{- end -}}

    {{- if $recoveryValue -}}
      {{- $_ := set $objectData "recoveryValue" $recoveryValue -}}
      {{- $recConfig := include "tc.v1.common.lib.cnpg.configmap.recoverystring" (dict $recoveryBaseKey $recoveryValue) | fromYaml -}}
      {{- $_ := set $.Values.configmap (printf "%s-%s" $objectData.shortName $recoveryBaseKey) $recConfig -}}
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

      {{- if eq $objectData.mode "recovery" -}}
        {{- include "tc.v1.common.lib.cnpg.cluster.recovery.validation" (dict "objectData" $objectData) -}}
      {{- end -}}
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
      {{- $_ := set $cnpg.creds "password" $dbPass -}}
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
