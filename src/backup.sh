#! /bin/sh

set -eu
set -o pipefail

if [ -z "$S3_ACCESS_KEY_ID" ]; then
  echo "You need to set the S3_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [ -z "$S3_SECRET_ACCESS_KEY" ]; then
  echo "You need to set the S3_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [ -z "$S3_BUCKET" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ -z "$POSTGRES_DATABASE" ]; then
  echo "You need to set the POSTGRES_DATABASE environment variable."
  exit 1
fi

if [ -z "$S3_PREFIX" ]; then
  S3_PREFIX=backup
fi

if [ -z "$POSTGRES_HOST" ]; then
  if [ -n "$POSTGRES_PORT_5432_TCP_ADDR" ]; then
    POSTGRES_HOST=$POSTGRES_PORT_5432_TCP_ADDR
    POSTGRES_PORT=$POSTGRES_PORT_5432_TCP_PORT
  else
    echo "You need to set the POSTGRES_HOST environment variable."
    exit 1
  fi
fi

if [ -z "$POSTGRES_USER" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ -z "$POSTGRES_PASSWORD" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable."
  exit 1
fi

if [ -z "$S3_ENDPOINT" ]; then
  aws_args=""
else
  aws_args="--endpoint-url "$S3_ENDPOINT/$S3_BUCKET""
fi


export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$S3_REGION
export PGPASSWORD=$POSTGRES_PASSWORD

echo "Creating backup of $POSTGRES_DATABASE database..."
START=$(date +%s)
pg_dump --format=custom \
        -h $POSTGRES_HOST \
        -p $POSTGRES_PORT \
        -U $POSTGRES_USER \
        -d $POSTGRES_DATABASE \
        $PGDUMP_EXTRA_OPTS \
        > db.dump
SIZE=$(ls -nlt db.dump | head -n1 | awk '{print $5}')

timestamp=$(date +"%Y-%m-%dT%H:%M:%S")
s3_uri_base="s3://${S3_PREFIX}/${POSTGRES_DATABASE}_${timestamp}.dump"

if [ -n "$PASSPHRASE" ]; then
  echo "Encrypting backup..."
  gpg --symmetric --batch --passphrase "$PASSPHRASE" db.dump
  rm db.dump
  local_file="db.dump.gpg"
  s3_uri="${s3_uri_base}.gpg"
else
  local_file="db.dump"
  s3_uri="$s3_uri_base"
fi

echo "Uploading backup to $S3_BUCKET..."
aws $aws_args s3 cp "$local_file" "$s3_uri"
rm "$local_file"

END=$(date +%s)

if [ "$ENABLE_METRICS" = true ]; then
  echo "Writing metrics..."
  sh write_metrics.sh /metrics/metrics "${START}" "${END}" "${SIZE}"
fi

echo "Backup complete."
