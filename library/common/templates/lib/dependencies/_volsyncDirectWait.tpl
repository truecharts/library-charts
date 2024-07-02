{{/*
This template generates a random password and ensures it persists across updates/edits to the chart
*/}}
{{- define "tc.v1.common.dependencies.volsync.directwait" -}}

enabled: true
type: system
imageSelector: kubectlImage
securityContext:
  runAsUser: 568
  runAsGroup: 568
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  allowPrivilegeEscalation: false
  privileged: false
  seccompProfile:
    type: RuntimeDefault
  capabilities:
    add: []
    drop:
      - ALL
resources:
  excludeExtra: true
  requests:
    cpu: 10m
    memory: 50Mi
  limits:
    cpu: 500m
    memory: 512Mi
command:
  - "/bin/sh"
  - "-c"
  - |
    /bin/bash <<'EOF'
    echo "Waiting till volsync replication from source is completed..."

    while :; do
      # Check for replicationDestinations with empty lastSync
      empty_syncs=$(kubectl get replicationDestination -n "{{ .Release.Namespace }}" -o json | jq -r '.items[] | select(.status.lastSync == null) | .metadata.name')

      # If no empty lastSync is found, break the loop
      if [ -z "$empty_syncs" ]; then
        echo "No replicationDestinations with empty last-sync found in namespace '$NAMESPACE'."
        break
      fi

      # Print the names of replicationDestinations with empty lastSync
      echo "Found replicationDestinations with empty last-sync in namespace '$NAMESPACE':"
      echo "$empty_syncs"

      # Optionally: Add a sleep interval to avoid excessive looping
      sleep 5
    done
    EOF
{{- end -}}
{{- end -}}

{{- define "tc.v1.common.dependencies.volsync.waitrbac" -}}
{{ $primarypresent := false }}
{{- range .values.rbac -}}
  {{ if and .enabled .primary }}
    {{ $primarypresent = true }}
  {{ end }}
{{ end }}
enabled: true
allServiceAccounts: true
primary: {{ $primarypresent }}
clusterWide: false
rules:
  - apiGroups:
      - "volsync.backube"
    resources:
      - replicationDestination
    verbs:
      - get
      - list
      - watch
{{- end -}}

{{- define "tc.v1.common.dependencies.volsync.primarywaitsa" -}}
enabled: true
primary: true
targetSelectAll: true
{{ end }}

{{/* TODO: adapt this to only assign to pods that need one */}}
{{- define "tc.v1.common.dependencies.volsync.extrawaitsa" -}}
enabled: true
primary: false
{{ end }}

{{- define "tc.v1.common.dependencies.volsync.waitsa.inject" -}}
{{ $primarypresent := false }}
{{ $extraSaReq := true }}

{{- range .values.serviceAccount -}}
  {{ if and .enabled .primary }}
    {{ $primarypresent = true }}
  {{ end }}
  {{ if and .enabled .targetSelectAll }}
    {{ $extraSaReq = false }}
  {{ end }}
{{ end }}

{{- if not $primarypresent -}}
{{- $sa := include "tc.v1.common.dependencies.volsync.primarywaitsa" $ | fromYaml -}}
{{- $_ := set .Values.serviceAccount "main" $sa -}}
{{ $extraSaReq = false }}
{{ end }}

{{/* TODO: We need to list of pods that have no SA assigned */}}

{{- if $extraSaReq -}}
{{/* TODO: if there are pods without SA, implement an SA anyway */}}
{{- $saextra := include "tc.v1.common.dependencies.volsync.extrawaitsa" $ | fromYaml -}}
{{- $_ := set .Values.serviceAccount "saextra" $saextra -}}
{{ end }}

{{- end -}}


{{- define "tc.v1.common.lib.deps.volsync.wait" -}}
  {{- $volSyncDetect := false -}}

  {{- range $name, $persistence := .Values.persistence -}}

    {{- $enabled := (include "tc.v1.common.lib.util.enabled" (dict
                    "rootCtx" $ "objectData" $persistence
                    "name" $name "caller" "Persistence"
                    "key" "persistence")) -}}

    {{- if eq $enabled "true" -}}

      {{/* Only spawn PVC if its enabled and any type of "pvc" */}}
      {{- $types := (list "pvc") -}}
      {{- if and (mustHas $objectData.type $types) (not $objectData.existingClaim) -}}

        {{/* Create VolSync objects */}}
        {{- range $volsync := $objectData.volsync -}}
          {{- $volsyncData := (mustDeepCopy $volsync) -}}
          {{- $destEnabled := eq (include "tc.v1.common.lib.util.enabled" (dict
                "rootCtx" $ "objectData" $volsync.dest
                "name" $volsync.name "caller" "VolSync Destination"
                "key" "volsync")) "true" -}}

          {{- if and $destEnabled ( eq $volsyncData.copyMethod "Snapshot" )-}}
            {{- $volSyncDetect := true -}}
          {{ end }}
        {{ end }}
      {{ end }}
    {{ end }}
  {{ end }}

{{- if $volSyncDetect -}}
    {{- $container := include "tc.v1.common.dependencies.volsync.directwait" $ | fromYaml -}}
    {{- if $container -}}
      {{- range .Values.workload -}}
        {{ $_ := set .podSpec.automountServiceAccountToken true }}
        {{- if not (hasKey .podSpec "initContainers") -}}
          {{- $_ := set .podSpec "initContainers" dict -}}
        {{- end -}}
      {{- $_ := set .podSpec.initContainers "redis-wait" $container -}}
      {{- end -}}
    {{- end -}}
{{- $rbac := include "tc.v1.common.dependencies.volsync.waitrbac" $ | fromYaml -}}
{{- $_ := set .Values.rbac "volsyncwait" dict -}}
{{- end-}}
{{- end-}}
