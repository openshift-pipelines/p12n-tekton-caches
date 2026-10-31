ARG GO_BUILDER=registry.redhat.io/ubi9/go-toolset:latest@sha256:cab9089469c52029e4d8a4e9f717e87c51ab22eed448ebcada101b811f97dfe7
ARG UBI_RUNTIME=registry.access.redhat.com/ubi9/ubi-minimal:latest@sha256:bba2b4bbf0ed15cfe7dd72a1e17ae7d2015a141f306b304e1a2785c41400e39c

FROM $GO_BUILDER AS builder

WORKDIR /go/src/github.com/openshift-pipelines/tekton-caches
COPY upstream .

ENV GOEXPERIMENT=strictfipsruntime
RUN git config --global --add safe.directory . && \
    go build -tags $GOEXPERIMENT  -v -o /tmp/cache  ./cmd/cache

FROM $UBI_RUNTIME
ARG VERSION=1.23

COPY --from=builder /tmp/cache /ko-app/cache


LABEL \
    com.redhat.component="openshift-pipelines-cache-rhel9-container" \
    cpe="cpe:/a:redhat:openshift_pipelines:1.23::el9" \
    description="Red Hat OpenShift Pipelines tekton-caches cache" \
    io.k8s.description="Red Hat OpenShift Pipelines tekton-caches cache" \
    io.k8s.display-name="Red Hat OpenShift Pipelines tekton-caches cache" \
    io.openshift.tags="tekton,openshift,tekton-caches,cache" \
    maintainer="pipelines-extcomm@redhat.com" \
    name="openshift-pipelines/pipelines-cache-rhel9" \
    summary="Red Hat OpenShift Pipelines tekton-caches cache" \
    version="v1.23.4"

RUN groupadd -r -g 65532 nonroot && useradd --no-log-init -rm -u 65532 -g nonroot nonroot
USER 65532
