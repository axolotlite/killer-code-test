**CronJob - Scheduling & Configuration**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

**CronJob - Scheduling & Configuration**

**Context**
You need to create and configure a **CronJob** that runs a periodic DNS resolution check using `busybox`. You will also need to **manually trigger** a one-off Job from the CronJob.

**Objectives**

* Create a **CronJob** with a specific schedule and container configuration
* Configure **job history limits** and **pod lifecycle settings**
* Manually create a **Job** from an existing **CronJob**

You can use the documentation:
- https://kubernetes.io/

keywords:
* `CronJob`

Page `CronJob - Kubernetes`
page keywords:
* `kind: cronjob`
* `successfulJobs`
* `failedJobs`

Page `Jobs | Kubernetes`
page keywords:
* `deadline`
