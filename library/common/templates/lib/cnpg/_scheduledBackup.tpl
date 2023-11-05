{{- define "tc.v1.common.lib.cnpg.spawner.scheduledBackups" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}

  {{- $scheduledBackupData := dict -}}
  {{- range $schedBackup := $objectData.backups.scheduledBackups -}}
    {{- $newObjectData := mustDeepCopy $objectData -}}
    {{- $_ := set $newObjectData "schedData" $schedBackup -}}

    {{- include "tc.v1.common.lib.cnpg.backup.validation" (dict "objectData" $newObjectData) }}
    {{- include "tc.v1.common.class.cnpg.scheduledbackup" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
  {{- end -}}
{{- end -}}
