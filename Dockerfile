ARG POSTGRES_VERSION
FROM postgres:17-alpine

ADD src/install.sh install.sh
RUN sh install.sh && rm install.sh && mkdir -p /metrics

ENV POSTGRES_DATABASE ''
ENV POSTGRES_HOST ''
ENV POSTGRES_PORT 5432
ENV POSTGRES_USER ''
ENV POSTGRES_PASSWORD ''
ENV PGDUMP_EXTRA_OPTS ''
ENV S3_ACCESS_KEY_ID ''
ENV S3_SECRET_ACCESS_KEY ''
ENV S3_BUCKET ''
ENV S3_REGION 'us-west-1'
ENV S3_PATH 'backup'
ENV S3_ENDPOINT ''
ENV S3_S3V4 'no'
ENV SCHEDULE ''
ENV PASSPHRASE ''

ADD src/run.sh run.sh
ADD src/backup.sh backup.sh
ADD src/restore.sh restore.sh
ADD src/write_metrics.sh write_metrics.sh

CMD ["sh", "run.sh"]
