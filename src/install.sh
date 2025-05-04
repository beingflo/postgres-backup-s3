#! /bin/sh

set -eux
set -o pipefail

apk update

# install tools
apk add gnupg python3 py3-pip aws-cli curl

# cleanup
rm -rf /var/cache/apk/*
