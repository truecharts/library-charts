{{/*
This template ensures pods with clickhouse dependency have a delayed start
*/}}
{{- define "tc.common.dependencies.clickhouse.init" -}}
{{- $clickhouseHost := printf "%v-%v" .Release.Name "clickhouse" }}
{{- if .Values.clickhouse.enabled }}
- name: clickhouse-init
  image: "{{ .Values.clickhouseImage.repository}}:{{ .Values.clickhouseImage.tag }}"
  securityContext:
    capabilities:
      drop:
        - ALL
  resources:
  {{- with .Values.resources }}
    {{- tpl ( toYaml . ) $ | nindent 4 }}
  {{- end }}
  command: [sh]
  args:
    - -c
    - until wget --quiet --tries=1 --spider {{ .Values.clickhouse.url.ping }}; do sleep 2; done
  imagePullPolicy: IfNotPresent
{{- end }}
{{- end -}}
