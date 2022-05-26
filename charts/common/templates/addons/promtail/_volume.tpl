{{/*
The volume (referencing config) to be inserted into additionalVolumes.
*/}}
{{- define "tc.common.v10.addon.promtail.volumeSpec" -}}
configMap:
  name: {{ include "tc.common.v10.names.fullname" . }}-promtail
{{- end -}}
