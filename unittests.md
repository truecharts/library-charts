Controller:
- [ ] Enable
- [ ] disble
- [ ] type: daemonset, deployment, statefullset
- [ ] annotationsList
- [ ] annotations
- [ ] LabelsList
- [ ] Labels
- [ ] replica's (on both daemonset and statefullset)
- [ ] strategy: all options for deployments and statefullsets
- [ ] rolingUpdate: test if values propage on both pod types
- [ ] check if revision history limit propagates on all deployment types

Images:
- [ ] image selector: test if selector works on all deployment types
- [ ] command: test if command propagates on all deployment types
- [ ] args: test if propagates on all deployment types
- [ ] extraArgs: test if propagates (and merges) on all deployment types
- [ ] TZ: test if propagates on all deployment types
- [ ] patchInitify: test if this can be disabled correctly

Portal:
- [ ] test if can be enabled
- [ ] test if path can be overrided
- [ ] test if the hostIP can be overrided
- [ ] test if the port can be overrided
- [ ] Ensure it correctly reads the main ingress when enabled
- [ ] Ensure it reads the correct main service when enabled (both loadbalancer and nodePort)
- [ ] (Test if possible, TBD:) ensure it correctly detects external interfaces and pick the first

pod:
- [ ] podAnnotations: check if correctly applied
- [ ] podAnnotationsList: check if merged and correctly applied
- [ ] podLabels: check if correctly applied
- [ ] podLabelsList: check if merged and correctly applied
- [ ] tty: check can be enabled
- [ ] stdin: check can be enabled

HPA:
- [ ] test if defaults are all set correctly on main HPA
- [ ] test if additional HPA's can be created with correct defaults
- [ ] targetKind: test can be set
- [ ] target: test can be set
- [ ] minReplicas: test can be set
- [ ] maxReplicas: test can be set
- [ ] targetCPUUtilizationPercentage: test can be set
- [ ] targetMemoryUtilizationPercentage: check if can be set

serviceAccount:
- [ ] test if main serviceAccount can be enabled
- [ ] test if additional serviceAccounts can be created
- [ ] test if other serviceaccount can be flagged as primary
- [ ] test if annotations can be set

rbac:
- [ ] test if can be enabled
- [ ] test if others can be created
- [ ] test if others can correctly be set as primary
- [ ] test if clusterRoleLabels can be set
- [ ] test if clusterRoleAnnotations can be set
- [ ] test if clusterRuleBinderingLabels can be set
- [ ] test if clusterRuleBindingAnnotations can be set
- [ ] test if rules can be set
- [ ] test if subjects can be added
- [ ] test if default subject is applied correctly
- [ ] test if the default serviceAccountName can be set

networkPolicy:
- [ ] test if can be enabled
- [ ] test if podSelector defaults to helm-chart selector labels
- [ ] test if policyTypes can be set
- [ ] test if egress can be set
- [ ] test if ingress can be set
- [ ] test if multiple can be added.

externalInterfaces:
(TO BE DONE)

secretEnv:
- [X] secret loaded as env when env vars are set
- [ ] secret created when env vars are set

env:
- [X] check if everything loaded as envs and can use tpl

secret:
- [ ] test if secret can get added
- [ ] test if example-secret is not loaded (test disble)
- [ ] test if data gets loaded into secret

priorityClassName:
- [ ] test if it gets parsed

schedulerName:
- [ ] test if it gets parsed

hostname:
- [ ] test if it gets parsed

hostNetwork:
- [ ] test if it gets enabled when enabled

dnsPolicy:
- [ ] test if default is "ClusterFirst"  when hostNetwork is false
- [ ] test if default is "ClusterFirstWithHostNet" when hostNetwork is true
- [ ] test is above defaults can be overriden manually.

dnsConfig:
- [ ] test the default ndots setting is correctly being set
- [ ] test if we can add more settings and they get parsed correctly

enableServiceLinks:
- [ ] Check if this can be enabled

security:
- [ ] Check if PUID results in the env-vars being set by default
- [ ] check us UMASK results in the env-vars being set by default
- [ ] Check we we can change PUID
- [ ] Check if we can change UMASK

customCapabilities:
- [ ] test if we can add capabilities through this
- [ ] test if we can drop capabilities through this

podSecurityContext:
- [ ] Test if the defaults are set correctly
- [ ] test if we can change runAsUser
- [ ] test if we can change runAsGroup
- [ ] test if we can change fsGroup
- [ ] test if we can add supplementalGroups
- [ ] test if we can change fsGroupChangePolicy

lifecycle:
- [ ] test if settings added here propagate into the chart correctly

installContainers:
- [ ] test if containers added here gets added
- [ ] test if TPL can be used
- [ ] ensure they are only run on install

upgradeContainers:
- [ ] test if the containers added here get added
- [ ] test if TPL can be used
- [ ] ensure they are only run on upgrade

initContainers:
- [ ] test if the containers specified here get added correctly.
- [ ] test if TPL can be used

additionalContainers:
- [ ] test if the containers added here get added
- [ ] test if TPL can be used

probes:
- [ ] test if each of the probe types can be disabled
- [ ] test if each of the probes can be set to TCP and UDP
- [ ] test if the path can be changed
- [ ] test if the spec can be changed
- [ ] check if service/port configs propagate to probes
- [ ] check if the custom options works

termination:
- [ ] check if the messagePath gets set correctly
- [ ] check if messagePolicy gets set correctly
- [ ] ensure default of gracePeriodSeconds gets set
- [ ] check if gracePeriodSeconds can get changed

serviceList:
- [ ] Ensure items here get merged with service

service:
TBD

ingressList:
- [ ] Ensure items here get merged with Ingress

Ingress:
TBD

deviceList:
- [ ] check if correct hostPath mountpoints are created
- [ ] check if automatic supplemental groups are set on SCALE

persistenceList:
- [ ] Ensure this is merged with persistenceList

configmap:
- [ ] ensure the default config configmap is not created by default (check disable)
- [ ] check if configmap can be enabled
- [ ] check if more configmaps can be added
- [ ] check if data makes it into the configmap

persistence:
- [ ] TBD

Autopermissions:
- [ ] Ensure initcontainer gets created
- [ ] Ensure script gets generated correctly
- [ ] ensure script gets altered based on fsGroup and persistence settings

volumeClaimTemplates:
- [ ] TBD

nodeSelector:
- [ ] ensure this propagates into the chart at all

Affinity:
- [ ] ensure this propagates into the chart at all

topologySpreadConstraints:
- [ ] ensure this propagates into the chart at all

tolerations:
- [ ] ensure this propagates into the chart at all

hostAliases:
- [ ] ensure these can be added

resources:
- [ ] Ensure limits can be altered
- [ ] Ensure requests can be altered
- [ ] test if custom resource settings can be appended here

scaleGPU:
- [ ] ensure this propagates (even without actuall SCALE or GPU present it should propagate something)
- [ ] ensure it sets the additional supplementalGroups
- [ ] add a fake nvidia gpu and test if our custom env-var gets set
- [ ] ensure the custom nvidia env-var is not present on non-scale deployments

addons:
- [ ] TBD
