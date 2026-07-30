GO ?= go

.PHONY: build test fmt run

build:
	$(GO) build -o bin/pixelforge ./cmd/pixelforge

test:
	$(GO) test ./...

fmt:
	$(GO) fmt ./...

run:
	$(GO) run ./cmd/pixelforge

