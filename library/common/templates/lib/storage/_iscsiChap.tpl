{{- define "tc.v1.common.lib.iscsi.chap" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $data := dict -}}

  {{- if $objectData.iscsi.authSession -}}
    {{- with $objectData.iscsi.chap.sessionUsername -}}
      {{- $_ := set $data "node.session.auth.username" (tpl . $rootCtx) -}}
    {{- end -}}

    {{- with $objectData.iscsi.chap.sessionPassword -}}
      {{- $_ := set $data "node.session.auth.password" (tpl . $rootCtx) -}}
    {{- end -}}

    {{- with $objectData.iscsi.chap.sessionUsernameInitiator -}}
      {{- $_ := set $data "node.session.auth.username_in" (tpl . $rootCtx) -}}
    {{- end -}}

    {{- with $objectData.iscsi.chap.sessionPasswordInitiator -}}
      {{- $_ := set $data "node.session.auth.password_in" (tpl . $rootCtx) -}}
    {{- end -}}
  {{- end -}}

  {{- if $objectData.iscsi.authDiscovery -}}
    {{- with $objectData.iscsi.chap.discoveryUsername -}}
      {{- $_ := set $data "discovery.sendtargets.auth.username" (tpl . $rootCtx) -}}
    {{- end -}}

    {{- with $objectData.iscsi.chap.discoveryPassword -}}
      {{- $_ := set $data "discovery.sendtargets.auth.password" (tpl . $rootCtx) -}}
    {{- end -}}

    {{- with $objectData.iscsi.chap.discoveryUsernameInitiator -}}
      {{- $_ := set $data "discovery.sendtargets.auth.username_in" (tpl . $rootCtx) -}}
    {{- end -}}

    {{- with $objectData.iscsi.chap.discoveryPasswordInitiator -}}
      {{- $_ := set $data "discovery.sendtargets.auth.password_in" (tpl . $rootCtx) -}}
    {{- end -}}
  {{- end -}}

  {{- $data -}}
{{- end -}}
