{{- define "tc.common.lib.util.manifest.update" -}}
{{- if .Values.manifests.enabled }}
{{- $fullName := include "tc.common.names.fullname" . -}}

{{- $manifestprevious := lookup "v1" "ConfigMap" "tc-system" "manifestversion" }}
{{- $manifestVersionOld := 0 }}
{{- $manifestversion := .Values.manifests.version }}
{{- if $manifestprevious }}
  {{- $manifestVersionOld = ( index $manifestprevious.data "manifestversion" )}}
{{- end }}
{{- if ge ( int $manifestversion ) ( int $manifestVersionOld ) }}
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
    kind: ConfigMap
    metadata:
      namespace: tc-system
      name: manifestversion
    data:
      manifestversion: "{{ .Values.manifests.version }}"
      metalLBVersion: "{{ .Values.manifests.metalLBVersion }}"
      prometheusVersion: "{{ .Values.manifests.prometheusVersion }}"
      traefikCRDVersion: "{{ .Values.manifests.traefikCRDVersion }}"
---
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: {{ .Release.Namespace }}
  name: {{ $fullName }}-ns-manifests
  annotations:
    "helm.sh/hook": pre-install, pre-upgrade
    "helm.sh/hook-weight": "-7"
    "helm.sh/hook-delete-policy": hook-succeeded,before-hook-creation
data:
  tcsys.yaml: |-
    apiVersion: v1
    kind: Namespace
    metadata:
      name: tc-system
  promop.yaml: |-
    apiVersion: v1
    kind: Namespace
    metadata:
      name: prometheus-operator
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
            - name: {{ $fullName }}-ns-manifests
              mountPath: /etc/nsmanifests
              readOnly: true
          command:
            - "/bin/sh"
            - "-c"
            - |
              /bin/bash <<'EOF'
              echo "installing namespaces..."
              kubectl apply --server-side --force-conflicts -f /etc/nsmanifests || echo "Failed applying namespaces..."
              echo "installing prometheus operator"
              kubectl apply --server-side --force-conflicts -f https://github.com/prometheus-operator/prometheus-operator/releases/download/v{{ .Values.manifests.prometheusVersion }}/bundle.yaml -n prometheus-operator
              echo "installing metallb backend..."
              kubectl apply --server-side --force-conflicts -f https://raw.githubusercontent.com/metallb/metallb/v{{ .Values.manifests.metalLBVersion }}/config/manifests/metallb-native.yaml || echo "Failed applying metallb manifest..."
              echo "installing traefik CRDs clusterwide..."
              kubectl apply --server-side --force-conflicts -k https://github.com/traefik/traefik-helm-chart/tree/v{{ .Values.manifests.traefikCRDVersion }}/traefik/crds
              echo "installing other manifests..."
              kubectl apply -f /etc/manifests --server-side  --force-conflicts=true  || echo "Failed applying other manifests..."
              EOF
      volumes:
        - name: {{ $fullName }}-manifests
          configMap:
            name: {{ $fullName }}-manifests
        - name: {{ $fullName }}-ns-manifests
          configMap:
            name: {{ $fullName }}-ns-manifests
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
