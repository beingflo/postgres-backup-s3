# Introduction

This project provides Docker images to periodically back up a PostgreSQL database to S3, and to restore from the backup as needed.

This is a fork created to support ARM architectures. For this the go-cron dependency was removed and replaced with a simple sleep timer.

> **WARNING:** There are various changes in here to make aws talk to Exoscale, it's untested if backup / restore works against other S3 providers

# Usage

## Backup

```yaml
postgres:
  image: postgres:13
  environment:
    POSTGRES_USER: user
    POSTGRES_PASSWORD: password

pg_backup_s3:
  image: eeshugerman/postgres-backup-s3:13
  environment:
    SCHEDULE: "@weekly"
    PASSPHRASE: passphrase
    S3_REGION: region
    S3_ACCESS_KEY_ID: key
    S3_SECRET_ACCESS_KEY: secret
    S3_BUCKET: my-bucket
    S3_PREFIX: backup
    POSTGRES_HOST: postgres
    POSTGRES_DATABASE: dbname
    POSTGRES_USER: user
    POSTGRES_PASSWORD: password
    ENABLE_METRICS: true
```

- Images are tagged by the major PostgreSQL version they support: `9`, `10`, `11`, `12`, or `13`.
- If `PASSPHRASE` is provided, the backup will be encrypted using GPG.
- Run `docker exec <container name> sh backup.sh` to trigger a backup ad-hoc

### Backup Metrics

Optionally you can also export backup metrics, e.g. size, start time in Prometheus
file format. To read the metrics, you'll have to mount the metrics folder to your host at `/metrics`.
The file is called `metrics.txt`.

```sh
$ docker run -v $(pwd)/metrics:/metrics -e ENABLE_METRICS=true -e ... siemens/postgres-backup-s3
```

## Restore

> **WARNING:** DATA LOSS! All database objects will be dropped and re-created.

### ... from latest backup

```sh
docker exec <container name> sh restore.sh
```

> **NOTE:** If your bucket has more than a 1000 files, the latest may not be restored -- only one S3 `ls` command is used

### ... from specific backup

```sh
docker exec <container name> sh restore.sh <timestamp>
```

# Acknowledgements

This project is a fork and re-structuring of @schickling's [postgres-backup-s3](https://github.com/schickling/dockerfiles/tree/master/postgres-backup-s3) and [postgres-restore-s3](https://github.com/schickling/dockerfiles/tree/master/postgres-restore-s3).

## Fork goals

- [x] dedicated repository
- [x] automated builds
- [x] support multiple PostgreSQL versions
- [x] backup and restore with one image
- [x] support encrypted (password-protected) backups
- [x] option to restore from specific backup by timestamp

## Other changes

- uses `pg_dump`'s `custom` format (see [docs](https://www.postgresql.org/docs/10/app-pgdump.html))
- doesn't use Python 2
- backup blobs and all schemas by default
- drop and re-create all database objects on restore
- some env vars renamed or removed
- filter backups on S3 by database name
