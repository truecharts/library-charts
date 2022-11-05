{{- define "tc.common.lib.util.manifest.update" -}}
{{- if .Values.manifests.enabled }}
{{- $fullName := include "tc.common.names.fullname" . -}}

{{- $manifestprevious := lookup "v1" "ConfigMap" "tc-system" "manifestVersion" }}
{{- $manifestVersionOld := 0 }}
{{- $manifestVersion := .Values.manifests.version }}
{{- if $manifestprevious }}
  {{- $manifestVersionOld = ( index $manifestprevious.data "manifestVersion" )}}
{{- end }}
{{- if gt ( int $manifestVersion ) ( int $manifestVersionOld ) }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: {{ .Release.Namespace }}
  name: {{ $fullName }}-manifests
  annotations:
    "helm.sh/hook": pre-install, pre-upgrade
    "helm.sh/hook-weight": "-7"
    "helm.sh/hook-delete-policy": hook-succeeded,before-hook-creation
data:
  tcman.yaml: |-
    apiVersion: v1
    kind: Namespace
    metadata:
      name: tc-system
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      namespace: tc-system
      name: manifestVersion
    data:
      manifestVersion: "{{ .Values.manifests.version }}"
      metalLBVersion: "{{ .Values.manifests.metalLBVersion }}"
---
apiVersion: batch/v1
kind: Job
metadata:
  namespace: {{ .Release.Namespace }}
  name: {{ $fullName }}-manifests
  annotations:
    "helm.sh/hook": pre-install, pre-upgrade
    "helm.sh/hook-weight": "-6"
    "helm.sh/hook-delete-policy": hook-succeeded,before-hook-creation
spec:
  template:
    spec:
      serviceAccountName: {{ $fullName }}-manifests
      containers:
        - name: {{ $fullName }}-manifests
          image: {{ .Values.ubuntuImage.repository }}:{{ .Values.ubuntuImage.tag }}
          volumeMounts:
            - name: {{ $fullName }}-manifests
              mountPath: /etc/manifests
              readOnly: true
          command:
            - "/bin/sh"
            - "-c"
            - |
              /bin/bash <<'EOF'
              echo "installing metallb backend..."
              kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v{{ .Values.manifests.metalLBVersion}}/config/manifests/metallb-native.yaml
              echo "installing other manifests..."
              kubectl apply -f /etc/manifests
              EOF
      volumes:
        - name: {{ $fullName }}-manifests
          configMap:
            name: {{ $fullName }}-manifests
      restartPolicy: Never
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ $fullName }}-manifests
  annotations:
    "helm.sh/hook": pre-install, pre-upgrade
    "helm.sh/hook-weight": "-7"
    "helm.sh/hook-delete-policy": hook-succeeded,before-hook-creation
rules:
  - apiGroups:  ["*"]
    resources:  ["*"]
    verbs:  ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ $fullName }}-manifests
  annotations:
    "helm.sh/hook": pre-install, pre-upgrade
    "helm.sh/hook-weight": "-7"
    "helm.sh/hook-delete-policy": hook-succeeded,before-hook-creation
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: {{ $fullName }}-manifests
subjects:
  - kind: ServiceAccount
    name: {{ $fullName }}-manifests
    namespace: {{ .Release.Namespace }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $fullName }}-manifests
  namespace: {{ .Release.Namespace }}
  annotations:
    "helm.sh/hook": pre-install, pre-upgrade
    "helm.sh/hook-weight": "-7"
    "helm.sh/hook-delete-policy": hook-succeeded,before-hook-creation
{{- end }}
{{- end }}
{{- end -}}
