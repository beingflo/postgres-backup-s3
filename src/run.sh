#! /bin/sh

set -eu

if [ "$S3_S3V4" = "yes" ]; then
    aws configure set default.s3.signature_version s3v4
fi

sleep 5;
while true
do
    /bin/sh backup.sh;
    sleep 3600;
done
