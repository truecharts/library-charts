{{/*
This template generates a random password and ensures it persists across updates/edits to the chart
*/}}
{{- define "tc.v1.common.dependencies.elasticsearch.secret" -}}

{{- if .Values.elasticsearch.enabled -}}
  {{/* Initialize variables */}}
  {{- $fetchname := printf "%s-elasticsearchcreds" .Release.Name -}}
  {{- $dbprevious := lookup "v1" "Secret" .Release.Namespace $fetchname -}}
  {{- $dbPass := randAlphaNum 50 -}}
  {{- $dbIndex := .Values.elasticsearch.elasticsearchDatabase | default "0" -}}

  {{/* If there are previous secrets, fetch values and decrypt them */}}
  {{- if $dbprevious -}}
    {{- $dbPass = (index $dbprevious.data "elasticsearch-password") | b64dec -}}
  {{- end -}}

  {{/* Prepare data */}}
  {{- $dbHost := printf "%v-%v" .Release.Name "elasticsearch" -}}
  {{- $portHost := printf "%v:9200" $dbHost -}}
  {{- $url := printf "http://%v:%v@%v/%v" .Values.elasticsearch.elasticsearchUsername $dbPass $portHost $dbIndex -}}
  {{- $hostPass := printf "%v:%v@%v" .Values.elasticsearch.elasticsearchUsername $dbPass $dbHost -}}

  {{/* Append some values to elasticsearch.creds, so apps using the dep, can use them */}}
  {{- $_ := set .Values.elasticsearch.creds "elasticsearchPassword" ($dbPass | quote) -}}
  {{- $_ := set .Values.elasticsearch.creds "plain" ($dbHost | quote) -}}
  {{- $_ := set .Values.elasticsearch.creds "plainhost" ($dbHost | quote) -}}
  {{- $_ := set .Values.elasticsearch.creds "plainport" ($portHost | quote) -}}
  {{- $_ := set .Values.elasticsearch.creds "plainporthost" ($portHost | quote) -}}
  {{- $_ := set .Values.elasticsearch.creds "plainhostpass" ($hostPass | quote) -}}
  {{- $_ := set .Values.elasticsearch.creds "url" ($url | quote) -}}

{{/* Create the secret (Comment also plays a role on correct formatting) */}}
enabled: true
expandObjectName: false
data:
  elasticsearch-password: {{ $dbPass }}
  plain: {{ $dbHost }}
  url: {{ $url }}
  plainhostpass: {{ $hostPass }}
  plainporthost: {{ $portHost }}
  plainhost: {{ $dbHost }}
  {{- end -}}
{{- end -}}

{{- define "tc.v1.common.dependencies.elasticsearch.injector" -}}
  {{- $secret := include "tc.v1.common.dependencies.elasticsearch.secret" . | fromYaml -}}
  {{- if $secret -}}
    {{- $_ := set .Values.secret (printf "%s-%s" .Release.Name "elasticsearchcreds") $secret -}}
  {{- end -}}
{{- end -}}
