{{- define "tc.v1.common.lib.util.operator.register" -}}
  {{- if .Values.operator.register -}}
    {{- with (lookup "v1" "ConfigMap" "tc-system" $.Chart.Name) -}}
      {{- fail "You cannot install the same operator twice..." -}}
    {{- end -}}

    {{- $objectData := (dict  "name"      $.Chart.Name
                              "namespace" "tc-system"
                              "data"      (dict "namespace" $.Release.Namespace
                                                "version"   $.Chart.Version)) -}}
    {{/* data.namespace   - The namespace the operator is installed in */}}
    {{/* data.version     - The version of the installed operator */}}
    {{- include "tc.v1.common.class.configmap" (dict "rootCtx" $ "objectData" $objectData) -}}
  {{- end -}}
{{- end -}}
