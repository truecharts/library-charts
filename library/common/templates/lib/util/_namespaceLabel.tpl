{{- define "tc.v1.common.lib.util.namespacelabel" -}}
  {{- if or .Values.namespace.name.label .Values.global.namespace.name.label -}}
    {{- $workload := include "tc.v1.common.lib.util.namespacelabel.workload" $ | fromYaml -}}
    {{- $rbac := include "tc.v1.common.lib.util.namespacelabel.rbac" $ | fromYaml -}}
    {{- $serviceaccount := include "tc.v1.common.lib.util.namespacelabel.serviceaccount" $ | fromYaml -}}
    {{- if $workload -}}
        {{- if not (hasKey .Values "workload") -}}
          {{- $_ := set .Values "workload" dict -}}
        {{- end -}}
      {{- $_ := set .Values.workload "namespacelabel" $workload -}}
    {{- end -}}
    {{- if $rbac -}}
        {{- if not (hasKey .Values "rbac") -}}
          {{- $_ := set .Values "rbac" dict -}}
        {{- end -}}
      {{- $_ := set .Values.rbac "namespacelabel" $rbac -}}
    {{- end -}}
    {{- if $serviceaccount -}}
        {{- if not (hasKey .Values "serviceaccount") -}}
          {{- $_ := set .Values "serviceaccount" dict -}}
        {{- end -}}
      {{- $_ := set .Values.serviceaccount "namespacelabel" $serviceaccount -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{- define "tc.v1.common.lib.util.namespacelabel.workload" -}}
# -- (docs/workload/README.md)
enabled: true
primary: true
type: job
automountServiceAccountToken: true
podSpec:
  containers:
    main:
      annotations:
        "helm.sh/hook": post-install,post-upgrade,post-rollback
        "helm.sh/hook-delete-policy": hook-succeeded
      enabled: true
      primary: true
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
      command:
        - "/bin/sh"
        - "-c"
        - |
        - /bin/sh
        - -c
        - |
          {{- range .Values.namespace.name.labels }}
          kubectl label namespace {{ include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $rootCtx "objectData" $objectData "caller" "NamespaceLabel") }} {{ .key }}={{ .value }}
          {{- end }}
          {{- range .Values.global.namespace.name.labels }}
          kubectl label namespace {{ include "tc.v1.common.lib.metadata.namespace" (dict "rootCtx" $rootCtx "objectData" $objectData "caller" "NamespaceLabel") }} {{ .key }}={{ .value }}
          {{- end }}
{{- end -}}

{{- define "tc.v1.common.lib.util.namespacelabel.rbac" -}}
enabled: true
primary: false
serviceAccounts:
  - labelnamespace
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["namespace"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
{{- end -}}

{{- define "tc.v1.common.lib.util.namespacelabel.serviceaccount" -}}
enabled: true
primary: false
{{- end -}}
