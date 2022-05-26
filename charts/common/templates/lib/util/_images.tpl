{{/* vim: set filetype=mustache: */}}
{{/*
Return the proper image name
{{ include "tc.common.v10.images.image" ( dict "imageRoot" .Values.path.to.the.image "global" $) }}
*/}}
{{- define "tc.common.v10.images.image" -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- $tag := .imageRoot.tag | toString -}}
{{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}

{{/*
Return the image name using the selector
{{ include "tc.common.v10.images.selector" . }}
*/}}
{{- define "tc.common.v10.images.selector" -}}
{{- $imageDict := get .Values "image" }}
{{- $selected := .Values.imageSelector }}
{{- if hasKey .Values $selected }}
{{- $imageDict = get .Values $selected }}
{{- end }}
{{- $repositoryName := $imageDict.repository -}}
{{- $tag :=$imageDict.tag | toString -}}
{{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names (deprecated: use tc.common.v10.images.renderPullSecrets instead)
{{ include "tc.common.v10.images.pullSecrets" ( dict "images" (list .Values.path.to.the.image1, .Values.path.to.the.image2) "global" .Values.global) }}
*/}}
{{- define "tc.common.v10.images.pullSecrets" -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names evaluating values as templates
{{ include "tc.common.v10.images.renderPullSecrets" ( dict "images" (list .Values.path.to.the.image1, .Values.path.to.the.image2) "context" $) }}
*/}}
{{- define "tc.common.v10.images.renderPullSecrets" -}}
{{- end -}}
