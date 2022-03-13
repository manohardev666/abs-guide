# abs-guide application deployment on Kubernetes.

This guide uses the `abs-guide` Helm Chart to deploy abs-guide application on Kubernetes after building nginx docker image.

## Overview

In this guide we will walk through the steps necessary to deploy a abs-guide application on Nginx web server using the `abs-guide` Helm Chart against a Kubernetes cluster. I will use `minikube` for this application, but the chart can also be used for different Kubernetes clusters (e.g EKS )

## Build and Package

The code for the site is contained in `index.html`, and the Nginx config is in `default.conf`. The Dockerfile contains commands to build a Docker Image.

To build a Docker image from the Dockerfile, run the following command from inside this directory

```sh
$ docker build -t <docker-hub-username>/abs-guide:1.0 .
```
This will produce the following output

```sh
Sending build context to Docker daemon 81.41 kB
Step 1/3 : FROM nginx:alpine
 ---> 2f3c6710d8f2
Step 2/3 : COPY default.conf /etc/nginx/conf.d/default.conf
 ---> Using cache
 ---> 176c56cc07b6
Step 3/3 : COPY abs-guide/* /usr/share/nginx/html
 ---> 3407953dafd0
Removing intermediate container cb64bb3e3aca
Successfully built 3407953dafd0


Here are the steps, linked to the relevant sections of this doc:


## Deploy abs-guide

Now that we have a working Kubernetes cluster with Helm installed and ready to go, the next step is to deploy application using the `abs-guide` chart.

```
helm install -f values.yaml ./helm
```

When you run this command, you should see output similar to below:

```
NAME:   abs-guide
LAST DEPLOYED: Sun March 13 09:14:39 2022
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME                 AGE
abs-guide  0s

==> v1/Deployment
abs-guide  0s

==> v1/Pod(related)

NAME                                READY  STATUS             RESTARTS  AGE
abs-guide-7b7bb49d-b8tf8  0/1    ContainerCreating  0         0s
abs-guide-7b7bb49d-fgjd4  0/1    ContainerCreating  0         0s
abs-guide-7b7bb49d-zxpcm  0/1    ContainerCreating  0         0s


NOTES:
Check the status of your Deployment by running this comamnd:

kubectl get deployments

List the related Pods with the following command:

kubectl get pods

Use the following command to view information about the Service:

kubectl get services


## Check the Status of the Deployment and pod

In the previous step, we deployed nginx webserver with abs-guide application using the `abs-guide` Helm Chart. Now we want to verify it has deployed
successfully.

```
$ kubectl get deployments
NAME                  DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
abs-guide   3         3         3            3           5m
```

```
$ kubectl get pods
NAME                                 READY     STATUS    RESTARTS   AGE
abs-guide-7b7bb49d-b8tf8   1/1       Running   0          13m
abs-guide-7b7bb49d-fgjd4   1/1       Running   0          13m
abs-guide-7b7bb49d-zxpcm   1/1       Running   0          13m
```

### How the service is exposed

A `Service` in Kubernetes is used to expose a group of `Pods` that match a given selector under a stable endpoint.
`Service` resources track which `Pods` are live and ready, and only route traffic to those that are in the `READY`
status. The `READY` status is managed using `readinessProbes`: as long as the `Pod` passes the readiness check, the
`Pod` will be marked `READY` and kept in the pool for the `Service`.

There are several different types of `Services`. For this , I used the type to be
`NodePort`. A `NodePort` `Service` exposes a port on the Kubernetes worker that routes to the `Service` endpoint. This
endpoint will load balance across the `Pods` that match the selector for the `Service`.

To access a `NodePort` `Service`, we need to first find out what port is exposed. We can do this by querying for the
`Service` using `kubectl`.
