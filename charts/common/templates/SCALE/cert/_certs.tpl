{{/*
Retrieve true/false if certificate is configured
*/}}
{{- define "tc.common.v10.scale.cert.available" -}}
{{- if .ObjectValues.certHolder.scaleCert -}}
{{- $values := (. | mustDeepCopy) -}}
{{- $_ := set $values "commonCertOptions" (dict "certKeyName" $values.ObjectValues.certHolder.scaleCert) -}}
{{- template "tc.common.v10.scale.cert_present" $values -}}
{{- else -}}
{{- false -}}
{{- end -}}
{{- end -}}


{{/*
Retrieve public key of certificate
*/}}
{{- define "tc.common.v10.scale.cert.publicKey" -}}
{{- $values := (. | mustDeepCopy) -}}
{{- $_ := set $values "commonCertOptions" (dict "certKeyName" $values.ObjectValues.certHolder.scaleCert "publicKey" true) -}}
{{ include "tc.common.v10.scale.cert" $values }}
{{- end -}}


{{/*
Retrieve private key of certificate
*/}}
{{- define "tc.common.v10.scale.cert.privateKey" -}}
{{- $values := (. | mustDeepCopy) -}}
{{- $_ := set $values "commonCertOptions" (dict "certKeyName" $values.ObjectValues.certHolder.scaleCert) -}}
{{ include "tc.common.v10.scale.cert" $values }}
{{- end -}}

{{/*
Retrieve true/false if certificate is available in ixCertificates
*/}}
{{- define "tc.common.v10.scale.cert_present" -}}
{{- $values := . -}}
{{- hasKey $values.Values.ixCertificates ($values.commonCertOptions.certKeyName | toString) -}}
{{- end -}}


{{/*
Retrieve certificate from variable name
*/}}
{{- define "tc.common.v10.scale.cert" -}}
{{- $values := . -}}
{{- $certKey := ($values.commonCertOptions.certKeyName | toString) -}}
{{- if hasKey $values.Values.ixCertificates $certKey -}}
{{- $cert := get $values.Values.ixCertificates $certKey -}}
{{- if $values.commonCertOptions.publicKey -}}
{{ $cert.certificate }}
{{- else -}}
{{ $cert.privatekey }}
{{- end -}}
{{- end -}}
{{- end -}}
