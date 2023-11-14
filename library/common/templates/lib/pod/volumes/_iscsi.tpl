{{/* Returns iscsi Volume */}}
{{/* Call this template:
{{ include "tc.v1.common.lib.pod.volume.iscsi" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the volume.
*/}}
{{- define "tc.v1.common.lib.pod.volume.iscsi" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- if not $objectData.scsi.targetPortal -}}
    {{- fail "Persistence - Expected non-empty [targetPortal] on [iscsi] type" -}}
  {{- end -}}

  {{- if not $objectData.scsi.iqn -}}
    {{- fail "Persistence - Expected non-empty [iqn] on [iscsi] type" -}}
  {{- end -}}

  {{- if not $objectData.scsi.lun -}}
    {{- fail "Persistence - Expected non-empty [lun] on [iscsi] type" -}}
  {{- end -}}
- name: {{ $objectData.shortName }}
  iscsi:
    targetPortal: {{ $objectData.scsi.targetPortal }}
    {{- with $objectData.scsi.portals -}}
    portals:
    {{- tpl (toYaml .) $rootCtx | nindent 4 }}
    {{- end -}}
    iqn: {{ $objectData.scsi.iqn }}
    lun: {{ $objectData.scsi.lun }}
    {{- with $objectData.scsi.iscsiInterface -}}
    iscsiInterface: {{ . }}
    {{- end -}}
    {{- with $objectData.scsi.fsType -}}
    fsType: {{ . }}
    {{- end -}}
    readOnly: {{ $objectData.scsi.targetPortal | default false }}
{{/* TODO: add chap auth support */}}
{{- end -}}
