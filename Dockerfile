FROM certbot/certbot

RUN apk update && apk add openssh sshpass mandoc man-pages cronie coreutils \
    && mkdir -p /var/spool/cron/crontabs \
    && mkdir -p /work \
    && echo '*/1 * * * * echo "hello world"' > /var/spool/cron/crontabs/root \
    && chmod 600 /var/spool/cron/crontabs/root \
    && rm -rf /tmp/* /var/tmp/*

COPY cron_root.txt /data/
COPY CronRootSync.sh /
COPY run.sh /

RUN chmod 777 /*.*


WORKDIR /app
COPY . /app
ENTRYPOINT ["/run.sh"]
