ARG GO_BUILDER=registry.redhat.io/ubi9/go-toolset:9.6
ARG RUNTIME=registry.access.redhat.com/ubi9/ubi-minimal@sha256:759f5f42d9d6ce2a705e290b7fc549e2d2cd39312c4fa345f93c02e4abb8da95

FROM $GO_BUILDER AS builder

WORKDIR /go/src/github.com/openshift-pipelines/tekton-caches
COPY upstream .

ENV GOEXPERIMENT=strictfipsruntime
RUN git config --global --add safe.directory . && \
    go build -tags $GOEXPERIMENT  -v -o /tmp/cache  ./cmd/cache

FROM $RUNTIME
ARG VERSION=tekton-caches-main

COPY --from=builder /tmp/cache /ko-app/cache


LABEL \
      com.redhat.component="openshift-pipelines-cache-rhel9-container" \
      cpe="cpe:/a:redhat:openshift_pipelines:1.22::el9" \
      description="Red Hat OpenShift Pipelines tekton-caches cache" \
      io.k8s.description="Red Hat OpenShift Pipelines tekton-caches cache" \
      io.k8s.display-name="Red Hat OpenShift Pipelines tekton-caches cache" \
      io.openshift.tags="tekton,openshift,tekton-caches,cache" \
      maintainer="pipelines-extcomm@redhat.com" \
      name="openshift-pipelines/pipelines-cache-rhel9" \
      summary="Red Hat OpenShift Pipelines tekton-caches cache" \
      version="v1.22.0"

RUN groupadd -r -g 65532 nonroot && useradd --no-log-init -rm -u 65532 -g nonroot nonroot
USER 65532
