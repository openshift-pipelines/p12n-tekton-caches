ARG GO_BUILDER=registry.redhat.io/ubi9/go-toolset:9.7
ARG RUNTIME=registry.access.redhat.com/ubi9/ubi-minimal@sha256:ecd4751c45e076b4e1e8d37ac0b1b9c7271930c094d1bcc5e6a4d6954c6b2289

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
      com.redhat.component="openshift-pipelines-tekton-caches" \
      name="openshift-pipelines/pipelines-tekton-caches-rhel9" \
      version=$VERSION \
      summary="Red Hat OpenShift Pipelines Tekton Caches" \
      maintainer="pipelines-extcomm@redhat.com" \
      description="Red Hat OpenShift Pipelines Tekton Caches" \
      io.k8s.display-name="Red Hat OpenShift Pipelines Tekton Caches" \
      io.k8s.description="Red Hat OpenShift Pipelines Tekton Caches" \
      io.openshift.tags="pipelines,tekton,openshift,tekton-caches"

RUN groupadd -r -g 65532 nonroot && useradd --no-log-init -rm -u 65532 -g nonroot nonroot
USER 65532
