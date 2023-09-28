{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to
this (by the DNS naming spec). If release name contains chart name it will
be used as a full name.
*/}}
{{- define "seaweedfs.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "seaweedfs.chart" -}}
{{- printf "%s-helm" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "seaweedfs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Inject extra environment vars in the format key:value, if populated
*/}}
{{- define "seaweedfs.extraEnvironmentVars" -}}
{{- if .extraEnvironmentVars -}}
{{- range $key, $value := .extraEnvironmentVars }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Return the proper filer image */}}
{{- define "filer.image" -}}
{{- if .Values.filer.imageOverride -}}
{{- $imageOverride := .Values.filer.imageOverride -}}
{{- printf "%s" $imageOverride -}}
{{- else -}}
{{- $registryName := default .Values.image.registry .Values.global.localRegistry | toString -}}
{{- $repositoryName := .Values.image.repository | toString -}}
{{- $name := .Values.global.imageName | toString -}}
{{- $tag := .Chart.AppVersion | toString -}}
{{- printf "%s%s%s:%s" $registryName $repositoryName $name $tag -}}
{{- end -}}
{{- end -}}

{{/* Return the proper dbSchema image */}}
{{- define "filer.dbSchema.image" -}}
{{- if .Values.filer.configuration.dbSchema.imageOverride -}}
{{- $imageOverride := .Values.filer.configuration.dbSchema.imageOverride -}}
{{- printf "%s" $imageOverride -}}
{{- else -}}
{{- $registryName := default .Values.global.registry .Values.global.localRegistry | toString -}}
{{- $repositoryName := .Values.global.repository | toString -}}
{{- $name := .Values.filer.configuration.dbSchema.imageName | toString -}}
{{- $tag := .Values.filer.configuration.dbSchema.imageTag | toString -}}
{{- printf "%s%s%s:%s" $registryName $repositoryName $name $tag -}}
{{- end -}}
{{- end -}}

{{/* Return the proper master image */}}
{{- define "master.image" -}}
{{- if .Values.master.imageOverride -}}
{{- $imageOverride := .Values.master.imageOverride -}}
{{- printf "%s" $imageOverride -}}
{{- else -}}
{{- $registryName := default .Values.image.registry .Values.global.localRegistry | toString -}}
{{- $repositoryName := .Values.image.repository | toString -}}
{{- $name := .Values.global.imageName | toString -}}
{{- $tag := .Chart.AppVersion | toString -}}
{{- printf "%s%s%s:%s" $registryName $repositoryName $name $tag -}}
{{- end -}}
{{- end -}}

{{/* Return the proper s3 image */}}
{{- define "s3.image" -}}
{{- if .Values.s3.imageOverride -}}
{{- $imageOverride := .Values.s3.imageOverride -}}
{{- printf "%s" $imageOverride -}}
{{- else -}}
{{- $registryName := default .Values.image.registry .Values.global.localRegistry | toString -}}
{{- $repositoryName := .Values.image.repository | toString -}}
{{- $name := .Values.global.imageName | toString -}}
{{- $tag := .Chart.AppVersion | toString -}}
{{- printf "%s%s%s:%s" $registryName $repositoryName $name $tag -}}
{{- end -}}
{{- end -}}

{{/* Return the proper volume image */}}
{{- define "volume.image" -}}
{{- if .Values.volume.imageOverride -}}
{{- $imageOverride := .Values.volume.imageOverride -}}
{{- printf "%s" $imageOverride -}}
{{- else -}}
{{- $registryName := default .Values.image.registry .Values.global.localRegistry | toString -}}
{{- $repositoryName := .Values.image.repository | toString -}}
{{- $name := .Values.global.imageName | toString -}}
{{- $tag := .Chart.AppVersion | toString -}}
{{- printf "%s%s%s:%s" $registryName $repositoryName $name $tag -}}
{{- end -}}
{{- end -}}

{{/* check if any Volume PVC exists */}}
{{- define "volume.pvc_exists" -}}
{{- $volumeDataPersistenceUsesPVC := false -}}
{{- range $i, $volume := .Values.volume.persistence.data.volumes -}}
{{- if not (empty $volume.existingClaim) -}}
{{- $volumeDataPersistenceUsesPVC = true -}}
{{- end -}}
{{- end -}}
{{- if or $volumeDataPersistenceUsesPVC .Values.volume.persistence.indices.existingClaim .Values.volume.persistence.logs.existingClaim -}}
{{- printf "true" -}}
{{- else -}}
{{- printf "" -}}
{{- end -}}
{{- end -}}

{{/* check if any Filer PVC exists */}}
{{- define "filer.pvc_exists" -}}
{{- if or .Values.filer.persistence.data.existingClaim .Values.filer.persistence.logs.existingClaim -}}
{{- printf "true" -}}
{{- else -}}
{{- printf "" -}}
{{- end -}}
{{- end -}}

{{/* check if any Master PVC exists */}}
{{- define "master.pvc_exists" -}}
{{- if or .Values.master.persistence.data.existingClaim .Values.master.persistence.logs.existingClaim -}}
{{- printf "true" -}}
{{- else -}}
{{- printf "" -}}
{{- end -}}
{{- end -}}

{{/* check if any InitContainers exist for Volumes */}}
{{- define "volume.initContainers_exists" -}}
{{- if or .Values.volume.persistence.indices.enabled (not (empty .Values.volume.initContainers )) -}}
{{- printf "true" -}}
{{- else -}}
{{- printf "" -}}
{{- end -}}
{{- end -}}

{{/* Return the proper imagePullSecrets */}}
{{- define "seaweedfs.imagePullSecrets" -}}
{{- if .Values.global.imagePullSecrets }}
{{- if kindIs "string" .Values.global.imagePullSecrets }}
imagePullSecrets:
  - name: {{ .Values.global.imagePullSecrets }}
{{- else }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Renders a value that contains template perhaps with scope if the scope is present.
Usage:
{{ include "common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $ ) }}
{{ include "common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $ "scope" $app ) }}
*/}}
{{- define "common.tplvalues.render" -}}
{{- $value := typeIs "string" .value | ternary .value (.value | toYaml) }}
{{- if contains "{{" (toJson .value) }}
  {{- if .scope }}
      {{- tpl (cat "{{- with $.RelativeScope -}}" $value "{{- end }}") (merge (dict "RelativeScope" .scope) .context) }}
  {{- else }}
    {{- tpl $value .context }}
  {{- end }}
{{- else }}
    {{- $value }}
{{- end }}
{{- end -}}

{{/* Return the proper imagePullSecrets */}}
{{- define "common.command.defaultReplicationValue" -}}
{{- if .Values.global.topologicalReplication.enabled }}
{{- $countInDifferentDataCenters := ternary 0 .Values.global.topologicalReplication.countInDifferentDataCenters (or (ge .Values.global.topologicalReplication.countInDifferentDataCenters 10) (lt .Values.global.topologicalReplication.countInDifferentDataCenters 0)) }}
{{- $countInSameDataCenterAndSameRack := ternary 0 .Values.global.topologicalReplication.countInSameDataCenterAndSameRack (or (ge .Values.global.topologicalReplication.countInSameDataCenterAndSameRack 10) (lt .Values.global.topologicalReplication.countInSameDataCenterAndSameRack 0)) }}
{{- $countInSameDataCenterButDifferentRacks := ternary 0 .Values.global.topologicalReplication.countInSameDataCenterButDifferentRacks (or (ge .Values.global.topologicalReplication.countInSameDataCenterButDifferentRacks 10) (lt .Values.global.topologicalReplication.countInSameDataCenterButDifferentRacks 0)) }}
{{ join "" (list $countInDifferentDataCenters $countInSameDataCenterButDifferentRacks $countInSameDataCenterAndSameRack | toStrings) }}
{{- end -}}
{{- end -}}

{{/*
ref: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_storage.tpl
Return  the proper Storage Class
{{ include "common.storage.class" ( dict "persistence" .Values.path.to.the.persistence "global" $) }}
*/}}
{{- define "common.storage.class" -}}
{{- $storageClass := .persistence.storageClass -}}
{{- if .global -}}
    {{- if .global.storageClass -}}
        {{- $storageClass = .global.storageClass -}}
    {{- end -}}
{{- end -}}
{{- if $storageClass -}}
  {{- if (eq "-" $storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else }}
      {{- printf "storageClassName: %s" $storageClass -}}
  {{- end -}}
{{- end -}}
{{- end -}}
