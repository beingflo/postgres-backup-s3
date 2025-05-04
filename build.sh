#!/usr/bin/env bash
die() { echo "$*" 1>&2 ; exit 1; }

docker buildx build -t "ghcr.io/beingflo/postgres-backup-s3:1.0" . || die "Failed to build docker image"
docker push "ghcr.io/beingflo/postgres-backup-s3:1.0" || die "Failed to push docker image"