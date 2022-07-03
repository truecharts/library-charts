{{/*
This template ensures pods with clickhouse dependency have a delayed start
TODO: implement health check with /ping endpoint
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
    - sleep 30
  imagePullPolicy: IfNotPresent
{{- end }}
{{- end -}}
