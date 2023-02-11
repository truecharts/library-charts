{{/* PVC - Storage Class Name */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pvc.storageClassName" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
rootCtx: The root context of the chart.
objectData: The object data of the pvc
*/}}
{{- define "ix.v1.common.lib.pvc.storageClassName" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}

  {{/*
    If storageClass is defined on the objectData:
      *  "-" returns "", which means requesting a PV without class
      *  "SCALE-ZFS" returns the value set on Values.global.ixChartContext.storageClassName
      (*)  "SCALE-SMB" returns the value set on Values.global.ixChartContext.smbStorageClassName (Example for the future)
      *   Else return the original defined storageClass

    Else if we are in an ixChartContext, always return the storageClassName defined on the ixChartContext

    Else if there is a storageClass defined in Values.fallbackDefaults.storageClass, return this

    In any other case, return nothing
  */}}

  {{- $className := "" -}}
  {{- if $objectData.storageClass -}}
    {{- $storageClass := (tpl $objectData.storageClass $rootCtx) -}}

    {{- if eq "-" $storageClass -}}
      {{- $className = "\"\"" -}}
    {{- else if eq "SCALE-ZFS" $storageClass -}}
      {{- if not $rootCtx.Values.global.ixChartContext.storageClassName -}}
        {{- fail "PVC - Expected non-empty <global.ixChartContext.storageClassName> on [SCALE-ZFS] storageClass" -}}
      {{- end -}}
      {{- $className = tpl $rootCtx.Values.global.ixChartContext.storageClassName $rootCtx -}}
    {{- else -}}
      {{- $className = tpl $storageClass $rootCtx -}}
    {{- end -}}

  {{- else if $rootCtx.Values.global.ixChartContext -}}
    {{- if not $rootCtx.Values.global.ixChartContext.storageClassName -}}
      {{- fail "PVC - Expected non-empty <global.ixChartContext.storageClassName>" -}}
    {{- end -}}
    {{- $className = tpl $rootCtx.Values.global.ixChartContext.storageClassName $rootCtx -}}

  {{- else if $rootCtx.Values.fallbackDefaults.storageClass -}}

    {{- $className = tpl $rootCtx.Values.fallbackDefaults.storageClass $rootCtx -}}

  {{- end -}}

  {{- $className -}}
{{- end -}}
