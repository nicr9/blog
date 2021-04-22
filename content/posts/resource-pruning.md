---
title: "OpenShift: Automated Resource Pruning"
author: nicr9
type: post
date: 2017-12-22T12:56:17Z
tags:
  - openshift
---

I've used `cronjobs` to implement a number of system automation tasks in the past and I'm going to run through a common example here; resource pruning in OpenShift.

If you're looking to tidy up old resources (`builds`, `deployments` or `images`) then OpenShift provides the `oc adm prune ...` command for doing just that. You can specify the resource type you want to target and provide criteria for which of those resources you want to preserve.

Generally cluster operators find it really useful for keeping things neat and tidy. The first thing clients ask me when they find out about this is how to automate it!

# Enter; The CronJob

If you're not familiar with a Kubernetes Job, it's a primitive for running `pods` that are expected to complete whatever work they're doing and then exit. The CronJob (tech preview in OpenShift v3.3, and [general availability in v3.9](https://docs.openshift.com/container-platform/3.9/dev_guide/cron_jobs.html)) is exactly what it sounds like: a `pod` that is run periodically on a schedule that you can specify with a cronstring.

Let's take a look:

```yaml
apiVersion: batch/v1beta1
  kind: CronJob
  metadata:
    name: prune-${PRUNE_RESOURCE}
    namespace: pruning
  spec:
    concurrencyPolicy: Allow
    jobTemplate:
      spec:
        template:
          metadata:
            labels:
              parent: prune-${PRUNE_RESOURCE}
          spec:
            containers:
            - command:
              - /usr/bin/bash
              - -c
              - "oc adm prune ${PRUNE_RESOURCE} ${PRUNE_OPTIONS} --confirm"
              image: registry.access.redhat.com/openshift3/ose-cli
              imagePullPolicy: Always
              name: oadm-prune-${PRUNE_RESOURCE}
              terminationMessagePath: /dev/termination-log
            restartPolicy: OnFailure
            serviceAccountName: pruner
            securityContext: {}
            terminationGracePeriodSeconds: 30
    schedule: ${PRUNE_SCHEDULE}
    suspend: false
  status: {}
```

In this example we're using the [`openshift3/ose-cli`](https://access.redhat.com/containers/?tab=overview#/registry.access.redhat.com/openshift3/ose) image (because it ships with `oc`) and running the `oc adm prune ...` command on a schedule.

The parameters are:

* `PRUNE_RESOURCE` - Either `builds`, `deployments` or `images`
* `PRUNE_OPTIONS` - Each resource type comes with it's own options for protecting more recent resource objects. See [the docs](https://docs.openshift.com/container-platform/3.11/admin_guide/pruning_resources.html#prune-operations) for more info.
* `PRUNE_SCHEDULE` - A cronstring e.g. `0 12 * * *` to run every day at noon.

## Permissions

You may have noticed the `serviceAccountName: pruner` in the above manifest. In order for our `pod` to run `oc adm ...` it will need special privileges provided by a `serviceaccount`.

Here's an example where I create `serviceaccount/pruner` with `clusterrole/cluster-admin` (but you could craft a less permissive role):

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pruner
  namespace: pruning
```

```yaml
apiVersion: v1
kind: ClusterRoleBinding
metadata:
  name: admin-pruner
roleRef:
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: pruner
  namespace: pruning
```

## Hard pruning images

When you run `oc adm prune images ...` you'll realise this command only cleans up the `imagestream` and `imagestreamtag` objects representing those images in etcd; it doesn't delete the images themselves from the registry. If you're trying to free up some space on the registry's volume this turns out to be less than helpful...

Once you've run an image prune you can move onto ["hard pruning" the registry](https://docs.openshift.com/container-platform/3.7/admin_guide/pruning_resources.html#hard-pruning-registry) which will force the registry to clean out images that are missing from etcd.

If I ever work on a suitable way of automating hard pruning with another CronJob then I'll update this post but for now I'll leave it as an exercise for the reader.

## Conclusion

The `cronjob` is a particularly useful primitive in Kubernetes/OpenShift. This isn't too surprising given how useful the `cron` unix utility is in general. It's particularly useful for automating system administration tasks.

If you come up with any other useful system admin automation using CronJobs, [reach out to me](https://twitter.com/nicr9_), I'd love to hear about it!
