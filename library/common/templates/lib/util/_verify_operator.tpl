{{- define "tc.v1.common.lib.util.operator.verifyAll" -}}
  {{- if .Values.operator.verify.enabled -}}
    {{/* Go over all operators that need to be verified */}}
    {{- range $opName := .Values.operator.verify.additionalOperators -}}
      {{- $operatorData := include "tc.v1.common.lib.util.operator.verify" (dict "rootCtx" $ "opName" $opName) -}}

      {{/* If the operator was not found */}}
      {{- if and (eq $operatorData "false") ($.Values.operator.verify.failOnError) -}}
        {{- fail (printf "Operator [%s] have to be installed first" $opName) -}}
      {{- else -}}
        {{- $operator := ($operatorData | fromJson) -}}
        {{- $_ := set $.Values.operator $opName $operator -}}
      
        {{/* Create/Update the Cache ConfigMap */}}
        {{- $cacheDataWrite := (dict  "enabled" true "data"  ($operator) -}}
        {{/* Name will be expanded to "release-name-chart-name-tc-data" */}}
        {{- $_ := set $.Values.configmap ( printf "operator-%s" $opName ) $cacheDataWrite -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "tc.v1.common.lib.util.operator.verify" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $opName := .opName -}}
  {{- $opExists := false -}}
  {{- $operatorData := "false" -}}
  {{- $cache := (lookup "v1" "ConfigMap" $rootCtx.Release.Namespace ( printf "%v-%v" ( include "tc.v1.common.lib.chart.names.fullname" $) $opName  ) ) -}}
  
  {{- if $cache -}}
    {{- if $cache.data -}}
      {{- $viaCache := (lookup "v1" "ConfigMap" $cache.data.namespace ( printf "%v-tc-data" ( include "tc.v1.common.lib.chart.names.fullname" $) ) ) -}}
      {{- if $viaCache -}}
        {{- if $viaCache.data -}}
          {{- $name := (get $viaCache.data "tc-operator-name") -}}
          {{- $version := (get $viaCache.data "tc-operator-version") -}}
  
          {{/* If fetched name matches the "$opName"... */}}
          {{- if eq $name $opName -}}
            {{- if $opExists -}}
              {{- fail (printf "Found duplicate configmaps for operator [%s]" $opName) -}}
            {{- end -}}
          
            {{/* Mark operator as found*/}}
            {{- $opExists = true -}}
            {{- $operatorData = dict "name" $name "namespace" $viaCache.metadata.namespace "version" $version -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{/* Go over all configmaps */}}
  {- if not $opExists -}}
    {{- range $index, $cm := (lookup "v1" "ConfigMap" "" "").items -}}
      {{- if $cm.data -}}
        {{/* If "tc-operator-name" does not exist will return "" */}}
        {{- $name := (get $cm.data "tc-operator-name") -}}
        {{- $version := (get $cm.data "tc-operator-version") -}}
  
        {{/* If fetched name matches the "$opName"... */}}
        {{- if eq $name $opName -}}
          {{- if $opExists -}}
            {{- fail (printf "Found duplicate configmaps for operator [%s]" $opName) -}}
          {{- end -}}
          {{/* Mark operator as found*/}}
          {{- $opExists = true -}}
          {{- $operatorData = dict "name" $name "namespace" $cm.metadata.namespace "version" $version -}}
          
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  
  {{/* Return the data stringified */}}
  {{- if $opExists -}}
  {{- $operatorData | toJson }}
  {{- else -}}
  {{- $opExists | toString -}}
  {{- end -}}
{{- end -}}
