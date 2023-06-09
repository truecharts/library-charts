{{/* Contains the auto-permissions job */}}
{{- define "tc.v1.common.lib.util.autoperms" -}}

{{- $permAllowedTypes := (list "hostPath" "pvc" "emptyDir") -}}
{{- $basePath := "/mounts" -}}

{{/* Init an empty dict to hold data */}}
{{- $mounts := dict -}}

{{/* Go over persistence */}}
{{- range $name, $mount := .Values.persistence -}}
  {{- if and $mount.enabled $mount.autoPermissions -}}
    {{/* If autoPermissions is enabled...*/}}
    {{- if or $mount.autoPermissions.chown $mount.autoPermissions.chmod -}}
      {{- $type := $.Values.fallbackDefaults.persistenceType -}}
      {{- if $mount.type -}}
        {{- $type = $mount.type -}}
      {{- end -}}

      {{- if not (mustHas $type $permAllowedTypes) -}}
        {{- fail (printf "Auto Permissions - Allowed persistent types for auto permissions are [%v], but got [%v]" (join ", " $permAllowedTypes) $type) -}}
      {{- end -}}

      {{- if $mount.readOnly -}}
        {{- fail (printf "Auto Permissions - You cannot change permissions/ownership automatically with readOnly enabled") -}}
      {{- end -}}

      {{- if not $mount.targetSelect -}}
        {{- $_ := set $mount "targetSelector" dict -}}
      {{- end -}}
      {{/* Add the autopermission job/container to the selector */}}
      {{- $_ := set $mount.targetSelector "autopermissions" (dict
                                            "autopermissions" (dict
                                                "mountPath" (printf "%v/%v" $basePath $name))) -}}
      {{/* Add some data regarding what actions to perform */}}
      {{- $_ := set $mounts $name $mount.autoPermissions -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- if $mounts }}
enabled: true
type: Job
annotations:
  "helm.sh/hook": pre-install, pre-upgrade
  "helm.sh/hook-weight": "3"
  "helm.sh/hook-delete-policy": hook-succeeded,before-hook-creation,hook-failed
podSpec:
  restartPolicy: Never
  containers:
    autopermissions:
      enabled: true
      primary: true
      imageSelector: alpineImage
      securityContext:
        runAsNonRoot: false
        runAsUser: 0
      resources:
        limits:
          cpu: 2000m
          memory: 2Gi
      probes:
        liveness:
          type: exec
          command:
            - cat
            - /tmp/healthy
        readiness:
          type: exec
          command:
            - cat
            - /tmp/healthy
        startup:
          type: exec
          command:
            - cat
            - /tmp/healthy
      command:
        - /bin/sh
        - -c
      args:
        - |
          echo "Starting autopermissions job..."
          touch /tmp/healthy

          echo "Automatically correcting ownership and permissions..."

          {{- range $name, $vol := $mounts }}
            {{- $mountPath := (printf "%v/%v" $basePath $name) -}}

            {{- $user := "" -}}
            {{- if $vol.user -}}
              {{- $user = $vol.user -}}
            {{- end -}}

            {{- $group := $.Values.securityContext.pod.fsGroup -}}
            {{- if $vol.group -}}
              {{- $group = $vol.group -}}
            {{- end -}}

            {{- $r := "" -}}
            {{- if $vol.recursive -}}
              {{- $r = "-$" -}}
            {{- end -}}

            {{/* Permissions */}}
            {{- if $vol.chmod }}
              echo "Automatically correcting permissions for {{ $mountPath }}..."
              before=$(stat -c "%a" {{ $mountPath }})
              chmod {{ $r }} {{ $vol.chmod }} {{ $mountPath }} || echo "Failed setting permissions using chmod..."
              echo "Permissions after: $before"
              echo "Permissions after: [$(stat -c "%a" {{ $mountPath }})]"
              echo ""
            {{- end -}}

            {{/* Ownership */}}
            {{- if $vol.chown }}
              echo "Automatically correcting ownership for {{ $mountPath }}..."
              before=$(stat -c "%u:%g" {{ $mountPath }})
                {{- if $.Values.ixChartContext }}
                  /usr/sbin/nfs4xdr_winacl -a chown -G {{ $vol.group }} {{ $r | lower }} -c "{{ $mountPath }}" -p "{{ $mountPath }}" || echo "Failed setting ownership using winacl..."
                {{- else }}
                  chown {{ $r }} -f {{ $vol.user }}:{{ $vol.group }} {{ $mountPath }} || echo "Failed setting ownership using chown..."
                {{- end }}

              echo "Ownership before: $before"
              echo "Ownership after: [$(stat -c "%u:%g" {{ $mountPath }})]"
              echo ""
            {{- end -}}
          {{- end -}}
{{- end -}}
{{- end -}}

{{- define "tc.v1.common.lib.util.autoperms.job" -}}
  {{- $job := (include "tc.v1.common.lib.util.autoperms" $) | fromYaml -}}
  {{- if $job -}}
    {{- $_ := set $.Values.workload "autopermissions" $job -}}
  {{- end -}}
{{- end -}}
