---
title: "Automatic resource pruning in OpenShift"
date: 2017-12-22T12:56:17Z
draft: true
---

I've used CronJobs to implement a number of system automation tasks in the past and I'm going to run through a common example here; resource pruning.

If you're looking to tidy up old resources (`builds`, `deployments` or `images`) then OpenShift provides the `oc adm prune ...` command for doing just that. You can specify the resource type to want to target and provide criteria for preserving certain resources. Generally cluster operators find it really useful. The main complaint that I've heard from some clients is that the command needs to be run manually.

# Enter; The CronJob

If you're not familiar with a Kubernetes Job, it's a primitive for running containers that are expected to complete whatever work they're doing and exit. The CronJob (tech preview since [OpenShift v3.3.1](https://docs.openshift.com/container-platform/3.7/dev_guide/cron_jobs.html#overview)) is exactly what it sounds like: a container that is run periodically on a schedule that you can specify with a cronstring.

Let's take a look:

```
apiVersion: batch/v2alpha1
  kind: CronJob
  metadata:
    name: prune-${PRUNE_RESOURCE}
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
              image: registry.access.redhat.com/openshift3/ose
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

In this example we're using the [`openshift3/ose`](https://access.redhat.com/containers/?tab=overview#/registry.access.redhat.com/openshift3/ose) image (because I know it ships with `oc`) and running the `oc adm prune ...` command on a schedule.

The params are:

* `PRUNE_RESOURCE` - Either `builds`, `deployments` or `images`
* `PRUNE_OPTIONS` - Each resource type comes with it's own options for protecting more recent resource objects
* `PRUNE_SCHEDULE` - A cronstring

I'll update this post soon and convert the above manifest to a template! This should make it much easier to manage these pruning CronJobs.

## So what's the catch!?

Well the thing that catches people out when they first start pruning images is that the `oc adm prune ...` command only cleans up the objects representing images in etcd; it doesn't delete the images themselves from the registry. Once you've run an image prune you can move onto ["hard pruning" the registry](https://docs.openshift.com/container-platform/3.7/admin_guide/pruning_resources.html#hard-pruning-registry) which will force the registry to clean out images that are missing from etcd.

If I come up with a suitable way of automating hard pruning with another CronJob then I'll update the post with that too!

## Conclusion

The CronJob is a particularly useful primitive in Kubernetes/OpenShift. This isn't too surprising given how useful the `cron` unix utility is in general. It's particularly useful for automating system administration tasks.

If you come up with any other useful system admin automation using CronJobs, [reach out to me](twitter.com/nicr9_), I'd love to hear about it!