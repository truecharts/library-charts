{{- define "tc.v1.common.lib.volsync.moversecuritycontext" -}}
  {{- $creds := .creds -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}
  {{- $volsyncData := .volsyncData -}}
  {{- $target := get $volsyncData .target -}}

  {{- $runAsUser := $rootCtx.Values.securityContext.container.runAsUser -}}
  {{- $runAsGroup := $rootCtx.Values.securityContext.container.runAsGroup -}}
  {{- $fsGroup := $rootCtx.Values.securityContext.pod.fsGroup -}}

  {{- if $target.moverSecurityContext -}}
    {{- with $target.moverSecurityContext.runAsUser -}} {{/* TODO: Handle 0 here */}}
      {{- $runAsUser = . | default $runAsUser -}}
    {{- end -}}
    {{- with $target.moverSecurityContext.runAsGroup -}} {{/* TODO: Handle 0 here */}}
      {{- $runAsGroup = . | default $runAsGroup -}}
    {{- end -}}
    {{- with $target.moverSecurityContext.fsGroup -}} {{/* TODO: Handle 0 here */}}
      {{- $fsGroup = . | default $fsGroup -}}
    {{- end -}}
  {{- end }}

moverSecurityContext:
  runAsUser: {{ $runAsUser }}
  runAsGroup: {{ $runAsGroup }}
  fsGroup: {{ $fsGroup }}
{{- end -}}
