{{/* PVC Spawwner */}}
{{/* Call this template:
{{ include "tc.v1.common.spawner.pvc" $ -}}
*/}}

{{- define "tc.v1.common.spawner.pvc" -}}

  {{- range $name, $persistence := .Values.persistence -}}

    {{- if $persistence.enabled -}}

      {{/* Create a copy of the persistence */}}
      {{- $objectData := (mustDeepCopy $persistence) -}}

      {{- $_ := set $objectData "type" ($objectData.type | default $.Values.fallbackDefaults.persistenceType) -}}

      {{/* Perform general validations */}}
      {{- include "tc.v1.common.lib.persistence.validation" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- include "tc.v1.common.lib.metadata.validation" (dict "objectData" $objectData "caller" "Persistence") -}}

      {{/* Only spawn PVC if its enabled and any type of "pvc" */}}
      {{- $types := (list "pvc") -}}
      {{- if and (mustHas $objectData.type $types) (not $objectData.existingClaim) -}}

        {{/* Set the name of the PVC */}}
        {{- $_ := set $objectData "name" (include "tc.v1.common.lib.storage.pvc.name" (dict "rootCtx" $ "objectName" $name "objectData" $objectData)) -}}
        {{- $_ := set $objectData "shortName" $name -}}

        {{- if and $objectData.static $objectData.static.mode (ne $objectData.static.mode "disabled") -}}
          {{- $_ := set $objectData "storageClass" ($objectData.storageClass | default $objectData.name) -}}
          {{- $_ := set $objectData "volumeName" $objectData.name -}}

          {{- if eq $objectData.static.mode "smb" -}}
            {{/* Validate SMB CSI */}}
            {{- include "tc.v1.common.lib.storage.smbCSI.validation" (dict "rootCtx" $ "objectData" $objectData) -}}

            {{- $_ := set $objectData "provisioner" "smb.csi.k8s.io" -}}
            {{- $_ := set $objectData.static "driver" "smb.csi.k8s.io" -}}

            {{/* Create secret with creds */}}
            {{- $secretData := (dict
                                  "name" $objectData.name
                                  "labels" ($objectData.labels | default dict)
                                  "annotations" ($objectData.annotations | default dict)
                                  "data" (dict "username" $objectData.static.username "password" $objectData.static.password)
                                ) -}}
            {{- with $objectData.domain -}}
              {{- $_ := set $secretData.data "domain" . -}}
            {{- end -}}
            {{- include "tc.v1.common.class.secret" (dict "rootCtx" $ "objectData" $secretData) -}}

          {{- else if eq $objectData.static.mode "nfs" -}}
            {{/* Validate NFS CSI */}}
            {{- include "tc.v1.common.lib.storage.nfsCSI.validation" (dict "rootCtx" $ "objectData" $objectData) -}}

            {{- $_ := set $objectData "provisioner" "nfs.csi.k8s.io" -}}
            {{- $_ := set $objectData.static "driver" "nfs.csi.k8s.io" -}}

          {{- else if eq $objectData.static.mode "custom" -}}

            {{- $_ := set $objectData "provisioner" $objectData.static.provisioner -}}
            {{- $_ := set $objectData.static "driver" $objectData.static.driver -}}

          {{- end -}}

          {{/* Create the PV */}}
          {{- include "tc.v1.common.class.pv" (dict "rootCtx" $ "objectData" $objectData) -}}

        {{- else if $objectData.volumeName -}}

          {{- $_ := set $objectData "storageClass" ($objectData.storageClass | default $objectData.name) -}}

        {{- end -}}

        {{/* Call class to create the object */}}
        {{- include "tc.v1.common.class.pvc" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
