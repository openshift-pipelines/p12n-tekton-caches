ARG GO_BUILDER=registry.redhat.io/ubi9/go-toolset:latest@sha256:c2bd0309bf78ae317024fdfc5602a31704e0dba9572f6d4b0bd4b681033dc965
ARG UBI_RUNTIME=registry.redhat.io/ubi9/ubi-minimal-pqc:latest@sha256:c7fdcf2617a608d07f95fa01d8936fc8bf898096a60e5ebc432aae8ead50ea6c

FROM $GO_BUILDER AS builder

WORKDIR /go/src/github.com/openshift-pipelines/tekton-caches
COPY upstream .

ENV GOEXPERIMENT=strictfipsruntime
RUN git config --global --add safe.directory . && \
    go build -tags $GOEXPERIMENT  -v -o /tmp/cache  ./cmd/cache

FROM $UBI_RUNTIME
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
    version="v1.24.4"

RUN groupadd -r -g 65532 nonroot && useradd --no-log-init -rm -u 65532 -g nonroot nonroot
USER 65532
