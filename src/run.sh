#! /bin/sh

set -eu

if [ "$S3_S3V4" = "yes" ]; then
    aws configure set default.s3.signature_version s3v4
fi

echo "Starting backup process";
echo "Running backup every ${SCHEDULE} seconds";

sleep 10;

while true
do
    echo "Running backup script";
    /bin/sh backup.sh;
    sleep ${SCHEDULE};
done
