{{- define "tc.v1.common.class.cnpg.cluster" -}}
  {{- $values := .Values.cnpg -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.cnpg -}}
      {{- $values = . -}}
    {{- end -}}
  {{- end -}}
  {{- $cnpgClusterName := $values.name -}}
  {{- $cnpgClusterLabels := $values.labels -}}
  {{- $cnpgClusterAnnotations := $values.annotations }}

---
apiVersion: {{ include "tc.v1.common.capabilities.cnpg.cluster.apiVersion" $ }}
kind: Cluster
metadata:
  name: {{ $cnpgClusterName }}
  {{- $labels := (mustMerge ($cnpgClusterLabels | default dict) (include "tc.v1.common.lib.metadata.allLabels" $ | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $ "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end }}
  {{- $annotations := (mustMerge ($cnpgClusterAnnotations | default dict) (include "tc.v1.common.lib.metadata.allAnnotations" $ | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $ "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
spec:
  instances: {{ $values.instances | default 2  }}

  superuserSecret:
    name: {{ $cnpgClusterName }}-superuser

  bootstrap:
    initdb:
      database: {{ $values.database | default "app" }}
      owner: {{ $values.user | default "app" }}
      secret:
        name: {{ $cnpgClusterName }}-user

  primaryUpdateStrategy: {{ $values.primaryUpdateStrategy | default "unsupervised" }}

  storage:
    pvcTemplate:
      {{- with (include "tc.v1.common.lib.storage.storageClassName" (dict "persistence" $values.storage "root" . )) | trim }}
      storageClassName: {{ . }}
      {{- end }}
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: {{ tpl ($values.storage.walsize | default $.Values.fallbackDefaults.vctSize) $ | quote }}

  walStorage:
    pvcTemplate:
      {{- with (include "tc.v1.common.lib.storage.storageClassName" (dict "persistence" $values.storage "root" $ )) | trim }}
      storageClassName: {{ . }}
      {{- end }}
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: {{ tpl ($values.storage.walsize | default $.Values.fallbackDefaults.vctSize) $ | quote }}

  monitoring:
    enablePodMonitor: {{ $values.monitoring.enablePodMonitor | default true }}

  nodeMaintenanceWindow:
    inProgress: false
    reusePVC: on

{{- $dbPass := "" }}
{{- $dbprevious := lookup "v1" "Secret" .Release.Namespace ( printf "%s-user" $cnpgClusterName ) }}
{{- if $dbprevious }}
  {{- $dbPass = ( index $dbprevious.data "user-password" ) | b64dec  }}
{{- else }}
  {{- $dbPass = $values.password | default ( randAlphaNum 62 ) }}
{{- end }}

{{- $pgPass := "" }}
{{- $pgprevious := lookup "v1" "Secret" .Release.Namespace ( printf "%s-superuser" $cnpgClusterName ) }}
{{- if $pgprevious }}
  {{- $pgPass = ( index $dbprevious.data "superuser-password" ) | b64dec  }}
{{- else }}
  {{- $pgPass = $values.superUserPassword | default ( randAlphaNum 62 ) }}
{{- end }}

{{- $std := ( ( printf "postgresql://%v:%v@%v-rw:5432/%v" $values.user $dbPass $cnpgClusterName $values.database  ) | b64enc | quote ) }}
{{- $nossl := ( ( printf "postgresql://%v:%v@%v-rw:5432/%v?sslmode=disable" $values.user $dbPass $cnpgClusterName $values.database  ) | b64enc | quote ) }}
{{- $porthost := ( ( printf "%s-rw:5432" $cnpgClusterName ) | b64enc | quote ) }}
{{- $host := ( ( printf "%s-rw" $cnpgClusterName ) | b64enc | quote ) }}
{{- $jdbc := ( ( printf "jdbc:postgresql://%v-rw:5432/%v" $cnpgClusterName $values.database  ) | b64enc | quote ) }}

{{- $superuserSecret := include "tc.v1.common.class.cnpg.secret.postgres" (dict "pgPass" $pgPass ) | fromYaml -}}
{{- if $superuserSecret -}}
  {{- $_ := set $.Values.secret ( printf "cnpg-%s-superuser" $values.shortName ) $superuserSecret -}}
{{- end -}}

{{- $userSecret := include "tc.v1.common.class.cnpg.secret.user" (dict "values" $values "dbPass" $dbPass ) | fromYaml -}}
{{- if $userSecret -}}
  {{- $_ := set $.Values.secret ( printf "cnpg-%s-user" $values.shortName ) $userSecret -}}
{{- end -}}

{{- $urlSecret := include "tc.v1.common.class.cnpg.secret.urls" (dict "std" $std "nossl" $nossl "porthost" $porthost "host" $host "jdbc" $jdbc) | fromYaml -}}
{{- if $urlSecret -}}
  {{- $_ := set $.Values.secret ( printf "cnpg-%s-urls" $values.shortName ) $urlSecret -}}
{{- end -}}

{{- $_ := set $values.creds "password" ( $dbPass | quote ) }}
{{- $_ := set $values.creds "superUserPassword" ( $pgPass | quote ) }}
{{- $_ := set $values.creds "std" $std }}
{{- $_ := set $values.creds "nossl" $nossl }}
{{- $_ := set $values.creds "porthost" $porthost }}
{{- $_ := set $values.creds "host" $host }}
{{- $_ := set $values.creds "jdbc" $jdbc }}

{{- end -}}


{{- define "tc.v1.common.class.cnpg.secret.postgres" -}}
{{- $pgPass := .pgPass }}
enabled: true
data:
  username: {{ "postgres" | b64enc | quote  }}
  password: {{ $pgPass | b64enc | quote }}
type: kubernetes.io/basic-auth
{{- end -}}


{{- define "tc.v1.common.class.cnpg.secret.user" -}}
{{- $dbPass := .dbPass }}
{{- $values := .values -}}
enabled: true
type: kubernetes.io/basic-auth
data:
  username: {{ $values.user | b64enc | quote }}
  password: {{ $dbPass | b64enc | quote }}
{{- end -}}

{{- define "tc.v1.common.class.cnpg.secret.urls" -}}
{{- $std := .std }}
{{- $nossl := .nossl }}
{{- $porthost := .porthost }}
{{- $host := .host }}
{{- $jdbc := .jdbc }}
enabled: true
data:
  std: {{ $std }}
  nossl: {{ $nossl }}
  porthost: {{ $porthost }}
  host: {{ $host }}
  jdbc: {{ $jdbc }}
{{- end -}}
