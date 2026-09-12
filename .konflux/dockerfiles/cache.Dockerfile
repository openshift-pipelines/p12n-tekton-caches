ARG GO_BUILDER=registry.access.redhat.com/ubi9/go-toolset:latest@sha256:685ccca486cc2c82b0818d835abecb1aed7a396e76ba416cfc47c28067f5d365
ARG RUNTIME=registry.access.redhat.com/ubi9/ubi-minimal@sha256:d235f607e1d6d833f031db107dc42206e4dd4d5aa9142c43d3771fb7f9bea76a

FROM $GO_BUILDER AS builder

WORKDIR /go/src/github.com/openshift-pipelines/tekton-caches
COPY upstream .

ENV GOEXPERIMENT=strictfipsruntime
RUN git config --global --add safe.directory . && \
    go build -tags $GOEXPERIMENT  -v -o /tmp/cache  ./cmd/cache

FROM $RUNTIME
ARG VERSION=1.22

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
    version="v1.22.6"

RUN groupadd -r -g 65532 nonroot && useradd --no-log-init -rm -u 65532 -g nonroot nonroot
USER 65532
