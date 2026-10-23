#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}

BUILD_DIR=${DIR}/../build/snap
LDFLAGS='-linkmode external -extldflags -static'

go build -ldflags "${LDFLAGS}" -o ${BUILD_DIR}/meta/hooks/install ./cmd/install
go build -ldflags "${LDFLAGS}" -o ${BUILD_DIR}/meta/hooks/configure ./cmd/configure
go build -ldflags "${LDFLAGS}" -o ${BUILD_DIR}/meta/hooks/pre-refresh ./cmd/pre-refresh
go build -ldflags "${LDFLAGS}" -o ${BUILD_DIR}/meta/hooks/post-refresh ./cmd/post-refresh
go build -ldflags "${LDFLAGS}" -o ${BUILD_DIR}/bin/cli ./cmd/cli
