{{- define "tc.v1.common.lib.util.manifest.manage" -}}
{{- if .Values.manifestManager.enabled }}
{{- $fullName := include "tc.v1.common.lib.chart.names.fullname" . }}
---
apiVersion: batch/v1
kind: Job
metadata:
  namespace: tc-system
  name: {{ $fullName }}-manifests
  annotations:
    "helm.sh/hook": pre-install, pre-upgrade
    "helm.sh/hook-weight": "-6"
    "helm.sh/hook-delete-policy": hook-succeeded,before-hook-creation,hook-failed
spec:
  template:
    spec:
      serviceAccountName: {{ $fullName }}-manifests
      containers:
        - name: {{ $fullName }}-manifests
          image: {{ .Values.kubectlImage.repository }}:{{ .Values.kubectlImage.tag }}
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
            requests:
              cpu: 10m
              memory: 50Mi
            limits:
              cpu: 4000m
              memory: 8Gi
          livenessProbe:
            exec:
              command:
              - cat
              - /tmp/healthy
            initialDelaySeconds: 10
            failureThreshold: 5
            successThreshold: 1
            timeoutSeconds: 5
            periodSeconds: 10
          readinessProbe:
            exec:
              command:
              - cat
              - /tmp/healthy
            initialDelaySeconds: 10
            failureThreshold: 5
            successThreshold: 2
            timeoutSeconds: 5
            periodSeconds: 10
          startupProbe:
            exec:
              command:
              - cat
              - /tmp/healthy
            initialDelaySeconds: 10
            failureThreshold: 60
            successThreshold: 1
            timeoutSeconds: 2
            periodSeconds: 5
          command:
            - "/bin/sh"
            - "-c"
            - |
              /bin/sh <<'EOF'
              touch /tmp/healthy
              echo "installing manifests..."
              kubectl apply --server-side --force-conflicts --grace-period 30 --v=4 -k https://github.com/truecharts/manifests/{{ if .Values.manifestManager.staging }}staging{{ else }}manifests{{ end }} || kubectl apply --server-side --force-conflicts --grace-period 30 -k https://github.com/truecharts/manifests/{{ if .Values.manifestManager.staging }}staging{{ else }}manifests || echo "job failed..."{{ end }}
              kubectl wait --namespace cnpg-system --for=condition=ready pod --selector=app.kubernetes.io/name=cloudnative-pg --timeout=90s || echo "metallb-system wait failed..."
              kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app=metallb --timeout=90s || echo "metallb-system wait failed..."
              kubectl wait --namespace cert-manager --for=condition=ready pod --selector=app.kubernetes.io/instance=cert-manager --timeout=90s || echo "cert-manager wait failed..."
              cmctl check api --wait=2m || echo "cmctl wait failed..."
              EOF
          volumeMounts:
            - name: {{ $fullName }}-manifests-temp
              mountPath: /tmp
            - name: {{ $fullName }}-manifests-home
              mountPath: /home/apps/
      restartPolicy: Never
      volumes:
        - name: {{ $fullName }}-manifests-temp
          emptyDir: {}
        - name: {{ $fullName }}-manifests-home
          emptyDir: {}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ $fullName }}-manifests
  annotations:
    "helm.sh/hook": pre-install, pre-upgrade
    "helm.sh/hook-weight": "-7"
    "helm.sh/hook-delete-policy": hook-succeeded,before-hook-creation,hook-failed
rules:
  - apiGroups:  ["*"]
    resources:  ["*"]
    verbs:  ["watch", "create", "update", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ $fullName }}-manifests
  annotations:
    "helm.sh/hook": pre-install, pre-upgrade
    "helm.sh/hook-weight": "-7"
    "helm.sh/hook-delete-policy": hook-succeeded,before-hook-creation,hook-failed
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: {{ $fullName }}-manifests
subjects:
  - kind: ServiceAccount
    name: {{ $fullName }}-manifests
    namespace: tc-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $fullName }}-manifests
  namespace: tc-system
  annotations:
    "helm.sh/hook": pre-install, pre-upgrade
    "helm.sh/hook-weight": "-7"
    "helm.sh/hook-delete-policy": hook-succeeded,before-hook-creation,hook-failed
automountServiceAccountToken: false
{{- end }}
{{- end -}}
