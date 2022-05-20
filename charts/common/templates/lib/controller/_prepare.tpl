{{/*
This template serves as the blueprint for the mountPermissions job that is run
before chart installation.
*/}}
{{- define "common.controller.prepare" -}}
{{- $group := .Values.podSecurityContext.fsGroup -}}
{{- $hostPathMounts := dict -}}
{{- range $name, $mount := .Values.persistence -}}
  {{- if and $mount.enabled $mount.setPermissions -}}
    {{- $name = default ( $name| toString ) $mount.name -}}
    {{- $_ := set $hostPathMounts $name $mount -}}
  {{- end -}}
{{- end }}
- name: autopermissions
  image: {{ .Values.alpineImage.repository }}:{{ .Values.alpineImage.tag }}
  securityContext:
    runAsUser: 0
    privileged: true
  resources:
  {{- with .Values.resources }}
    {{- tpl ( toYaml . ) $ | nindent 4 }}
  {{- end }}
  command:
    - "/bin/sh"
    - "-c"
    - |
      /bin/bash <<'EOF'
      echo 'Automatically correcting permissions...'
      {{- if and ( .Values.addons.vpn.configFile.enabled ) ( not ( eq .Values.addons.vpn.type "disabled" )) }}
      chown -R 568:568 /vpn/vpn.conf; chmod -R g+w /vpn/vpn.conf || echo 'chmod failed for vpn config, are you running NFSv4 ACLs?'
      {{- end }}
      {{- range $_, $hpm := $hostPathMounts }}
      chown -R :{{ tpl $group $ }} {{ tpl $hpm.mountPath $ | squote }}
      chmod -R g+rwx {{ tpl $hpm.mountPath $ | squote }} || echo 'chmod failed for {{ tpl $hpm.mountPath $ }}, are you running NFSv4 ACLs?'
      {{- end }}
      echo 'increasing inotify limits...'
      ( sysctl -w fs.inotify.max_user_watches=524288 || echo 'error setting inotify') && ( sysctl -w fs.inotify.max_user_instances=512 || echo 'error setting inotify')
      EOF

  volumeMounts:
    {{- range $name, $hpm := $hostPathMounts }}
    - name: {{ $name }}
      mountPath: {{ $hpm.mountPath }}
      {{- if $hpm.subPath }}
      subPath: {{ $hpm.subPath }}
      {{- end }}
    {{- end }}
    {{- if and ( .Values.addons.vpn.configFile.enabled ) ( not ( eq .Values.addons.vpn.type "disabled" )) }}
    - name: vpnconfig
      mountPath: /vpn/vpn.conf
    {{- end }}
{{- end -}}
