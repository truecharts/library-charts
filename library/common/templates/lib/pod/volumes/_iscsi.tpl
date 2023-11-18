{{/* Returns iscsi Volume */}}
{{/* Call this template:
{{ include "tc.v1.common.lib.pod.volume.iscsi" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the volume.
*/}}
{{- define "tc.v1.common.lib.pod.volume.iscsi" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- if not $objectData.iscsi -}}
    {{- fail "Persitsence - Expected non-empty [iscsi] object on [iscsi] type" -}}
  {{- end -}}

  {{- $validFSTypes := (list "ext4" "xfs" "ntfs") -}}
  {{- if and $objectData.iscsi.fsType (not (mustHas $objectData.iscsi.fsType $validFSTypes)) -}}
    {{- fail (printf "Persistence - Expected [fsType] on [iscsi] type to be one of [%s], but got [%s]" (join ", " $validFSTypes) $objectData.iscsi.fsType) -}}
  {{- end -}}

  {{- if not $objectData.iscsi.targetPortal -}}
    {{- fail "Persistence - Expected non-empty [targetPortal] on [iscsi] type" -}}
  {{- end -}}

  {{- if not $objectData.iscsi.iqn -}}
    {{- fail "Persistence - Expected non-empty [iqn] on [iscsi] type" -}}
  {{- end -}}

  {{- if (kindIs "invalid" $objectData.iscsi.lun) -}}
    {{- fail "Persistence - Expected non-empty [lun] on [iscsi] type" -}}
  {{- end }}

- name: {{ $objectData.shortName }}
  iscsi:
    targetPortal: {{ $objectData.iscsi.targetPortal }}
    {{- with $objectData.iscsi.portals -}}
    portals:
      {{- range $portal := . }}
      - {{ tpl $portal $rootCtx | quote }}
      {{- end -}}
    {{- end -}}
    iqn: {{ $objectData.iscsi.iqn }}
    lun: {{ include "tc.v1.common.helper.makeIntOrNoop" $objectData.iscsi.lun }}
    {{- with $objectData.iscsi.iscsiInterface -}}
    iscsiInterface: {{ . }}
    {{- end -}}
    {{- with $objectData.iscsi.initiatorName -}}
    initiatorName: {{ . }}
    {{- end -}}
    {{- with $objectData.iscsi.fsType -}}
    fsType: {{ . }}
    {{- end -}}
{{/* TODO: add chap auth support */}}
{{- end -}}
