{{- define "tc.v1.common.lib.cnpg.fix.missing.keys" -}}
  {{- $objectData := .objectData -}}

  {{/* If monitoring key is no defined, create it so we dont get nil pointers */}}
  {{- if not (hasKey $objectData "monitoring") -}}
    {{- $_ := set $objectData "monitoring" dict -}}
  {{- end -}}

  {{/* If backups key is no defined, create it so we dont get nil pointers */}}
  {{- if not (hasKey $objectData "backups") -}}
    {{- $_ := set $objectData "backups" (dict "provider" "") -}}
  {{- end -}}

  {{/* If recovery key is no defined, create it so we dont get nil pointers
    {{- $_ := set $objectData "recovery" (dict "method" "") -}}
  {{- end -}}

  {{- if not (hasKey $objectData.recovery "pitrTarget") -}}
    {{- $_ := set $objectData.recovery "pitrTarget" dict -}}
  {{- end -}}

  {{- if not (hasKey $objectData.cluster "walStorage") -}}
    {{- $_ := set $objectData.cluster "walStorage" dict -}}
  {{- end -}}

  {{- if not (hasKey $objectData.cluster "storage") -}}
    {{- $_ := set $objectData.cluster "storage" dict -}}
  {{- end -}}

  {{- if not (hasKey $objectData.cluster "monitoring") -}}
    {{- $_ := set $objectData.cluster "monitoring" dict -}}
  {{- end -}}

  {{- if not (hasKey $objectData.cluster "initdb") -}}
    {{- $_ := set $objectData.cluster "initdb" dict -}}
  {{- end -}}*/}}
{{- end -}}
