PREFIX            ?= $(shell pwd)
FILES_TO_FMT      ?= $(shell find . -path ./vendor -prune -o -name '*.go' -print)

# Ensure everything works even if GOPATH is not set, which is often the case.
# The `go env GOPATH` will work for all cases for Go 1.8+.
GOPATH            ?= $(shell go env GOPATH)

# TMP_GOPATH is used to install tools with specified version
# in a way that does not mess up with go modules.
TMP_GOPATH        ?= /tmp/github.com/ppanyukov/go-boot

#GOBIN             ?= $(firstword $(subst :, ,${GOPATH}))/bin
GOBIN             = $(shell pwd)/bin

GO111MODULE       ?= on
export GO111MODULE
GOPROXY           ?= https://proxy.golang.org
export GOPROXY

# Tools.
EMBEDMD           ?= $(GOBIN)/embedmd-$(EMBEDMD_VERSION)
# v2.0.0
EMBEDMD_VERSION   ?= 97c13d6e41602fc6e397eb51c45f38069371a969

LICHE             ?= $(GOBIN)/liche-$(LICHE_VERSION)
LICHE_VERSION     ?= 2a2e6e56f6c615c17b2e116669c4cdb31b5453f3

GOIMPORTS         ?= $(GOBIN)/goimports-$(GOIMPORTS_VERSION)
GOIMPORTS_VERSION ?= 9d4d845e86f14303813298ede731a971dd65b593

PROMU             ?= $(GOBIN)/promu-$(PROMU_VERSION)
PROMU_VERSION     ?= 9583e5a6448f97c6294dca72dd1d173e28f8d4a4

PROTOC            ?= $(GOBIN)/protoc-$(PROTOC_VERSION)
PROTOC_VERSION    ?= 3.4.0

# v0.55.3 This needs to match with version in netlify.toml
HUGO_VERSION      ?= 993b84333cd75faa224d02618f312a0e96b53372
HUGO              ?= $(GOBIN)/hugo-$(HUGO_VERSION)

# v3.1.1
GOBINDATA_VERSION ?= a9c83481b38ebb1c4eb8f0168fd4b10ca1d3c523
GOBINDATA         ?= $(GOBIN)/go-bindata-$(GOBINDATA_VERSION)

GIT               ?= $(shell which git)

GOLANGCILINT_VERSION ?= d2b1eea2c6171a1a1141a448a745335ce2e928a1
GOLANGCILINT         ?= $(GOBIN)/golangci-lint-$(GOLANGCILINT_VERSION)

MISSPELL_VERSION     ?= c0b55c8239520f6b5aa15a0207ca8b28027ba49e
MISSPELL             ?= $(GOBIN)/misspell-$(MISSPELL_VERSION)


# fetch_go_bin_version downloads (go gets) the binary from specific version and installs it in $(GOBIN)/<bin>-<version>
# arguments:
# $(1): Install path. (e.g github.com/campoy/embedmd)
# $(2): Tag or revision for checkout.
# TODO(bwplotka): Move to just using modules, however make sure to not use or edit Thanos go.mod file!
define fetch_go_bin_version
	@mkdir -p $(GOBIN)
	@mkdir -p $(TMP_GOPATH)

	@echo ">> fetching $(1)@$(2) revision/version"
	@if [ ! -d '$(TMP_GOPATH)/src/$(1)' ]; then \
    GOPATH='$(TMP_GOPATH)' GO111MODULE='off' go get -d -u '$(1)/...'; \
  else \
    CDPATH='' cd -- '$(TMP_GOPATH)/src/$(1)' && git fetch; \
  fi
	@CDPATH='' cd -- '$(TMP_GOPATH)/src/$(1)' && git checkout -f -q '$(2)'
	@echo ">> installing $(1)@$(2)"
	@GOBIN='$(TMP_GOPATH)/bin' GOPATH='$(TMP_GOPATH)' GO111MODULE='off' go install '$(1)'
	@mv -- '$(TMP_GOPATH)/bin/$(shell basename $(1))' '$(GOBIN)/$(shell basename $(1))-$(2)'
	@echo ">> produced $(GOBIN)/$(shell basename $(1))-$(2)"
endef


.PHONY: all
all: format test lint build

# assets packs all static assets in `assets` dir into `pkg/assets/bindata.go` files
# which gets compiled into the binary.
.PHONY: assets
assets: $(GOBINDATA)
	@echo ">> deleting asset file"
	@rm pkg/assets/bindata.go || true
	@echo ">> writing assets"
	@$(GOBINDATA) $(bindata_flags) -pkg assets -o pkg/assets/bindata.go assets/...
	@go fmt ./pkg/assets

# build builds binaries using `promu`.
.PHONY: build
build: check-git deps $(PROMU)
	@echo ">> building binaries $(GOBIN)"
	@$(PROMU) build --prefix $(PREFIX)

# same as build but not checking git or modules
.PHONY: build-fast
build-fast: $(PROMU)
	@echo ">> building-fast binaries $(GOBIN)"
	@$(PROMU) build --prefix $(PREFIX)

# crossbuild builds all binaries for all platforms.
.PHONY: crossbuild
crossbuild: $(PROMU)
	@echo ">> crossbuilding all binaries"
	$(PROMU) crossbuild -v

# deps ensures fresh go.mod and go.sum.
.PHONY: deps
deps:
	@go mod tidy
	@go mod verify

# format formats the code (including imports format).
.PHONY: format
format: $(GOIMPORTS)
	@echo ">> formatting code"
	@$(GOIMPORTS) -w $(FILES_TO_FMT)

.PHONY: promu
promu: $(PROMU)

# test runs all Thanos golang tests against each supported version of Prometheus.
.PHONY: test
test: check-git install-deps
	@go test $(shell go list ./... | grep -v /vendor/);


# install-deps installs dependencies for e2e tetss.
# It installs supported versions of Prometheus and alertmanager to test against in e2e.
.PHONY: install-deps
install-deps: $(ALERTMANAGER) $(MINIO_SERVER) $(PROMS)
	@echo ">>GOBIN=$(GOBIN)"

# tooling deps. TODO(bwplotka): Pin them all to certain version!
.PHONY: check-git
check-git:
ifneq ($(GIT),)
	@test -x $(GIT) || (echo >&2 "No git executable binary found at $(GIT)."; exit 1)
else
	@echo >&2 "No git binary found."; exit 1
endif

.PHONY: lint
# PROTIP:
# Add
#      --cpu-profile-path string   Path to CPU profile output file
#      --mem-profile-path string   Path to memory profile output file
#
# to debug big allocations during linting.
lint: check-git $(GOLANGCILINT) $(MISSPELL)
	@echo ">> linting all of the Go files GOGC=${GOGC}"
	@$(GOLANGCILINT) run --enable goimports --enable goconst --skip-dirs vendor
	@echo ">> detecting misspells"
	@find . -type f | grep -v vendor/ | grep -vE '\./\..*' | xargs $(MISSPELL) -error

# non-phony targets
$(EMBEDMD):
	$(call fetch_go_bin_version,github.com/campoy/embedmd,$(EMBEDMD_VERSION))

$(GOIMPORTS):
	$(call fetch_go_bin_version,golang.org/x/tools/cmd/goimports,$(GOIMPORTS_VERSION))

$(LICHE):
	$(call fetch_go_bin_version,github.com/raviqqe/liche,$(LICHE_VERSION))

$(PROMU):
	$(call fetch_go_bin_version,github.com/prometheus/promu,$(PROMU_VERSION))

$(HUGO):
	@go get github.com/gohugoio/hugo@$(HUGO_VERSION)
	@mv $(GOBIN)/hugo $(HUGO)
	@go mod tidy

$(GOBINDATA):
	$(call fetch_go_bin_version,github.com/go-bindata/go-bindata/go-bindata,$(GOBINDATA_VERSION))

$(GOLANGCILINT):
	$(call fetch_go_bin_version,github.com/golangci/golangci-lint/cmd/golangci-lint,$(GOLANGCILINT_VERSION))

$(MISSPELL):
	$(call fetch_go_bin_version,github.com/client9/misspell/cmd/misspell,$(MISSPELL_VERSION))

$(ALERTMANAGER):
	$(call fetch_go_bin_version,github.com/prometheus/alertmanager/cmd/alertmanager,$(ALERTMANAGER_VERSION))

$(PROTOC):
	@mkdir -p $(TMP_GOPATH)
	@echo ">> fetching protoc@${PROTOC_VERSION}"
	@PROTOC_VERSION="$(PROTOC_VERSION)" TMP_GOPATH="$(TMP_GOPATH)" scripts/installprotoc.sh
	@echo ">> installing protoc@${PROTOC_VERSION}"
	@mv -- "$(TMP_GOPATH)/bin/protoc" "$(GOBIN)/protoc-$(PROTOC_VERSION)"
	@echo ">> produced $(GOBIN)/protoc-$(PROTOC_VERSION)"
