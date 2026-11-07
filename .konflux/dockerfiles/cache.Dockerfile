ARG GO_BUILDER=registry.access.redhat.com/ubi10/go-toolset:latest@sha256:cb712e78c45e429142e846c1b8b91894970eab3b66fd5a95d336b65b4f7bb877
ARG UBI_RUNTIME=registry.access.redhat.com/ubi10/ubi-minimal:latest@sha256:c3fe95ec9f53a3888c47314eb4d08bde09ebde646a428137b445091afe1daf89

FROM $GO_BUILDER AS builder

WORKDIR /go/src/github.com/openshift-pipelines/tekton-caches
COPY upstream .

ENV GOEXPERIMENT=strictfipsruntime
RUN git config --global --add safe.directory . && \
    go build -tags $GOEXPERIMENT  -v -o /tmp/cache  ./cmd/cache

FROM $UBI_RUNTIME
ARG VERSION=nightly

COPY --from=builder /tmp/cache /ko-app/cache


LABEL \
    com.redhat.component="openshift-pipelines-cache-rhel10-container" \
    cpe="cpe:/a:redhat:openshift_pipelines:nightly::el10" \
    description="Red Hat OpenShift Pipelines tekton-caches cache" \
    io.k8s.description="Red Hat OpenShift Pipelines tekton-caches cache" \
    io.k8s.display-name="Red Hat OpenShift Pipelines tekton-caches cache" \
    io.openshift.tags="tekton,openshift,tekton-caches,cache" \
    maintainer="pipelines-extcomm@redhat.com" \
    name="openshift-pipelines/pipelines-cache-rhel10" \
    summary="Red Hat OpenShift Pipelines tekton-caches cache" \
    version="nightly"

# ubi10/ubi-minimal does not ship shadow-utils, which provides groupadd/useradd
RUN microdnf install -y shadow-utils && \
    groupadd -r -g 65532 nonroot && useradd --no-log-init -rm -u 65532 -g nonroot nonroot
USER 65532
