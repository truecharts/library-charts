{{/* Loads all spawners */}}
{{- define "tc.v1.common.loader.apply" -}}

  {{/* Render ConfigMap(s) */}}
  {{- include "tc.v1.common.spawner.configmap" . | nindent 0 -}}

  {{/* Render Certificate(s) */}}
  {{- include "tc.v1.common.spawner.certificate" . | nindent 0 -}}

  {{/* Render Secret(s) */}}
  {{- include "tc.v1.common.spawner.secret" . | nindent 0 -}}

  {{/* Render Image Pull Secrets(s) */}}
  {{- include "tc.v1.common.spawner.imagePullSecret" . | nindent 0 -}}

  {{/* Render Service Accounts(s) */}}
  {{- include "tc.v1.common.spawner.serviceAccount" . | nindent 0 -}}

  {{/* Render RBAC(s) */}}
  {{- include "tc.v1.common.spawner.rbac" . | nindent 0 -}}

  {{/* Render External Interface(s) */}}
  {{- include "tc.v1.common.spawner.externalInterface" . | nindent 0 -}}

  {{/* Render Workload(s) */}}
  {{- include "tc.v1.common.spawner.workload" . | nindent 0 -}}

  {{/* Render Services(s) */}}
  {{- include "tc.v1.common.spawner.service" . | nindent 0 -}}

  {{/* Render PVC(s) */}}
  {{- include "tc.v1.common.spawner.pvc" . | nindent 0 -}}

{{- end -}}
