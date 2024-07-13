{{- define "tc.v1.common.lib.volsync.storage" -}}
  {{- $creds := .creds -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}
  {{- $volsyncData := .volsyncData -}}
  {{- $target := get $volsyncData .target -}}

  {{- if (mustHas $volsyncData.copyMethod (list "Clone" "Snapshot")) -}}
    {{- $accessModes := $rootCtx.Values.global.fallbackDefaults.accessModes -}}
    {{- if $objectData.accessModes }}
      {{- $accessModes = $objectData.accessModes }}
    {{- end }}
    {{- if $target.accessModes }}
      {{- $accessModes = $target.accessModes }}
    {{- end }}
    {{- $storageClassName := $rootCtx.Values.global.fallbackDefaults.storageClass -}}
    {{- if $objectData.storageClass }}
      {{- $storageClassName = $objectData.storageClass }}
    {{- end }}
    {{- if $target.storageClassName }}
      {{- $storageClassName = $target.storageClassName }}
    {{- end -}}

    {{- with $storageClassName }}
storageClassName: {{ . }}
    {{- end }}

accessModes:
    {{- range $accessModes }}
  - {{ . }}
    {{- end }}
  {{- end -}}

  {{- if eq $volsyncData.copyMethod "Snapshot" -}}
    {{- with $target.volumeSnapshotClassName }}
volumeSnapshotClassName: {{ . }}
    {{- end -}}
  {{- end -}}
{{- end -}}
