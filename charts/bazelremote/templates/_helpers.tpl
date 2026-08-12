{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes resources have name length limits.
*/}}
{{- define "bazelremote.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Headless Service name. Gives each shard a stable DNS name that HAProxy hashes traffic to.
*/}}
{{- define "bazelremote.headlessName" -}}
{{- printf "%s-headless" (include "bazelremote.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Name of the HAProxy consistent-hash router in front of the shards.
*/}}
{{- define "bazelremote.haproxyName" -}}
{{- printf "%s-haproxy" (include "bazelremote.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}
