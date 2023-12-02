{{- define "tc.v1.common.lib.cnpg.spawner.pooler" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- if not (hasKey $objectData "pooler") -}}
    {{- $_ := set $objectData "pooler" dict -}}
  {{- end -}}

  {{- $_ := set $objectData.pooler "type" "rw" -}}
  {{/* Validate Pooler */}}
  {{- include "tc.v1.common.lib.cnpg.pooler.validation" (dict "objectData" $objectData) -}}
  {{/* Create the RW Pooler object  */}}
  {{- include "tc.v1.common.class.cnpg.pooler" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}

  {{- if $objectData.pooler.createRO -}}
    {{- $_ := set $objectData.pooler "type" "ro" -}}

    {{/* Validate Pooler */}}
    {{- include "tc.v1.common.lib.cnpg.pooler.validation" (dict "objectData" $objectData) -}}
    {{/* Create the RO Pooler object  */}}
    {{- include "tc.v1.common.class.cnpg.pooler" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
  {{- end -}}

{{- end -}}
