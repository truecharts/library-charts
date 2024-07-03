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
        echo "No replicationDestinations with empty last-sync found in namespace [{{ .Release.Namespace }}]."
        break
      fi

      # Print the names of replicationDestinations with empty lastSync
      echo "Found replicationDestinations with empty last-sync in namespace [{{ .Release.Namespace }}]:"
      echo "$empty_syncs"

      # Optionally: Add a sleep interval to avoid excessive looping
      sleep 5
    done
    EOF
{{- end -}}

{{- define "tc.v1.common.dependencies.volsync.waitrbac" -}}

  {{- $result := include "tc.v1.common.lib.rbac.hasPrimaryOnEnabled" (dict "rootCtx" $) | fromJson }}
enabled: true
allServiceAccounts: true
primary: {{ not $result.hasPrimary }}
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

{{/* TODO: adapt this to only assign to pods that need one */}}
{{- define "tc.v1.common.dependencies.volsync.extrawaitsa" -}}
enabled: true
primary: false
{{- end -}}

{{- define "tc.v1.common.dependencies.volsync.waitsa.inject" -}}
  {{- $result := include "tc.v1.common.lib.rbac.hasPrimaryOnEnabled" (dict "rootCtx" $) | fromJson -}}
  {{- $hasPrimary := $result.hasPrimary -}}
  {{- $hasTargetSelectAll := $result.hasTargetSelectAll -}}

  {{- $saName := "" -}}

  {{/* If there is no primary service account, use the main one */}}
  {{- if not $hasPrimary -}}
    {{- $saName = "main" -}}
  {{/* If there is a primary but no targetSelectAll, create a new one */}}
  {{- else if $hasTargetSelectAll -}}
    {{- $saName = "volsync-wait-sa" -}}
  {{- end -}}

  {{/* Sanity check */}}
  {{- if not $saName -}}
    {{- fail "VolSync Wait - Failed to generate a service account name" -}}
  {{- end -}}

  {{- $_ := set .Values.serviceAccount $saName (dict
    "enabled" true "primary" not $hasPrimary "targetSelectAll" true
  ) -}}

{{- end -}}

{{- define "tc.v1.common.lib.deps.volsync.wait" -}}
  {{- $volSyncDetect := false -}}

  {{- range $name, $persistence := $.Values.persistence -}}
    {{- $objectData := mustDeepCopy $persistence -}}

    {{- $enabled := (include "tc.v1.common.lib.util.enabled" (dict
                    "rootCtx" $ "objectData" $objectData
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
                "name" $volsync.name "caller" "VolSync Wait"
                "key" "volsync")) "true" -}}

          {{- if and $destEnabled (eq $volsyncData.copyMethod "Snapshot") -}}
            {{- $volSyncDetect = true -}}
          {{- end -}}

        {{- end -}}
      {{- end -}}

    {{- end -}}
  {{- end -}}

  {{- if $volSyncDetect -}}
    {{- $container := include "tc.v1.common.dependencies.volsync.directwait" $ | fromYaml -}}
    {{- if $container -}}
      {{- range $workload := .Values.workload -}}
        {{- $_ := set $workload.podSpec "automountServiceAccountToken" true -}}
        {{- if not (hasKey $workload.podSpec "initContainers") -}}
          {{- $_ := set $workload.podSpec "initContainers" dict -}}
        {{- end -}}

        {{- $_ := set $workload.podSpec.initContainers "volsync-wait" $container -}}
      {{- end -}}
    {{- end -}}

    {{- $rbac := include "tc.v1.common.dependencies.volsync.waitrbac" $ | fromYaml -}}
    {{- $_ := set .Values.rbac "volsync-wait" $rbac -}}
  {{- end -}}
{{- end -}}
