{{- define "tc.v1.common.lib.cnpg.secrets" -}}
  {{- $objectData := .objectData -}}
  {{- $cnpg := .cnpg -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $dbPass := $objectData.password -}}

  {{- $creds := (dict
    "std" (printf "postgresql://%v:%v@%v-rw:5432/%v" $objectData.user $dbPass $objectData.name $objectData.database)
    "nossl" (printf "postgresql://%v:%v@%v-rw:5432/%v?sslmode=disable" $objectData.user $dbPass $objectData.name $objectData.database)
    "porthost" (printf "%s-rw:5432" $objectData.name)
    "host" (printf "%s-rw" $objectData.name)
    "jdbc" (printf "jdbc:postgresql://%v-rw:5432/%v" $objectData.name $objectData.database)
  ) -}}
  {{- $credsRO := dict -}}
  {{- if $objectData.pooler.createRO -}}
    {{- $credsRO = (dict
      "stdRO" (printf "postgresql://%v:%v@%v-ro:5432/%v" $objectData.user $dbPass $objectData.name $objectData.database)
      "nosslRO" (printf "postgresql://%v:%v@%v-ro:5432/%v?sslmode=disable" $objectData.user $dbPass $objectData.name $objectData.database)
      "porthostRO" (printf "%s-ro:5432" $objectData.name)
      "hostRO" (printf "%s-ro" $objectData.name)
      "jdbcRO" (printf "jdbc:postgresql://%v-ro:5432/%v" $objectData.name $objectData.database)
    ) -}}
  {{- end -}}

  {{- with (include "tc.v1.common.lib.cnpg.secret.user" (dict "user" $objectData.user "pass" $dbPass) | fromYaml) -}}
    {{- $_ := set $rootCtx.Values.secret (printf "cnpg-%s-user" $objectData.shortName) . -}}
  {{- end -}}

  {{- with (include "tc.v1.common.lib.cnpg.secret.urls" (dict "creds" $creds "credsRO" $credsRO) | fromYaml) -}}
    {{- $_ := set $rootCtx.Values.secret (printf "cnpg-%s-urls" $objectData.shortName) . -}}
  {{- end -}}

  {{/* We need to mutate the actual (cnpg) values here not the copy */}}
  {{- if not (hasKey $cnpg "creds") -}}
    {{- $_ := set $cnpg "creds" dict -}}
  {{- end -}}

  {{- $_ := set $cnpg.creds "password" $dbPass -}}

  {{- $_ := set $cnpg.creds "std" $creds.std -}}
  {{- $_ := set $cnpg.creds "nossl" $creds.nossl -}}
  {{- $_ := set $cnpg.creds "porthost" $creds.porthost -}}
  {{- $_ := set $cnpg.creds "host" $creds.host -}}
  {{- $_ := set $cnpg.creds "jdbc" $creds.jdbc -}}

  {{- if $objectData.pooler.createRO -}}
    {{- $_ := set $cnpg.creds "stdRO" $credsRO.stdRO -}}
    {{- $_ := set $cnpg.creds "nosslRO" $credsRO.nosslRO -}}
    {{- $_ := set $cnpg.creds "porthostRO" $credsRO.porthostRO -}}
    {{- $_ := set $cnpg.creds "hostRO" $credsRO.hostRO -}}
    {{- $_ := set $cnpg.creds "jdbcRO" $credsRO.jdbcRO -}}
  {{- end -}}

{{- end -}}

{{- define "tc.v1.common.lib.cnpg.secret.urls" -}}
  {{- $creds := .creds }}
  {{- $credsRO := .credsRO }}
enabled: true
data:
  std: {{ $creds.std }}
  nossl: {{ $creds.nossl }}
  porthost: {{ $creds.porthost }}
  host: {{ $creds.host }}
  jdbc: {{ $creds.jdbc }}
  {{- if $credsRO }}
  stdRO: {{ $creds.stdRO }}
  nosslRO: {{ $creds.nosslRO }}
  porthostRO: {{ $creds.porthostRO }}
  hostRO: {{ $creds.hostRO }}
  jdbcRO: {{ $creds.jdbcRO }}
  {{- end -}}
{{- end -}}

{{- define "tc.v1.common.lib.cnpg.secret.user" -}}
  {{- $user := .user -}}
  {{- $pass := .pass }}
enabled: true
type: kubernetes.io/basic-auth
data:
  username: {{ $user }}
  password: {{ $pass }}
{{- end -}}
