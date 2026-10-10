ARG GO_BUILDER=registry.access.redhat.com/ubi9/go-toolset:latest@sha256:6f246e8913d082df463b62a74c72f0d2b410583e1b2ac48add39cd7ede59ce62
ARG RUNTIME=registry.access.redhat.com/ubi9/ubi-minimal@sha256:5ed244b62bbf4095080144d9d35eb8fcd3d39a9801f94aadd63b9d10978a01ae

FROM $GO_BUILDER AS builder

WORKDIR /go/src/github.com/openshift-pipelines/tekton-caches
COPY upstream .

ENV GOEXPERIMENT=strictfipsruntime
RUN git config --global --add safe.directory . && \
    go build -tags $GOEXPERIMENT  -v -o /tmp/cache  ./cmd/cache

FROM $RUNTIME
ARG VERSION=1.24

COPY --from=builder /tmp/cache /ko-app/cache


LABEL \
    com.redhat.component="openshift-pipelines-cache-rhel9-container" \
    cpe="cpe:/a:redhat:openshift_pipelines:1.24::el9" \
    description="Red Hat OpenShift Pipelines tekton-caches cache" \
    io.k8s.description="Red Hat OpenShift Pipelines tekton-caches cache" \
    io.k8s.display-name="Red Hat OpenShift Pipelines tekton-caches cache" \
    io.openshift.tags="tekton,openshift,tekton-caches,cache" \
    maintainer="pipelines-extcomm@redhat.com" \
    name="openshift-pipelines/pipelines-cache-rhel9" \
    summary="Red Hat OpenShift Pipelines tekton-caches cache" \
    version="v1.24.2"

RUN groupadd -r -g 65532 nonroot && useradd --no-log-init -rm -u 65532 -g nonroot nonroot
USER 65532
