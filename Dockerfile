FROM certbot/certbot

RUN apk update && apk add openssh sshpass mandoc man-pages cronie \
    && mkdir -p /var/spool/cron \
    && mkdir -p /work \
    && echo '*/1 * * * * echo "hello world"' > /var/spool/cron/root \
    && chmod 600 /var/spool/cron/root \
    && rm -rf /tmp/* /var/tmp/*

ADD cron_root.txt /data/
ADD CronRootSync.sh /
ADD run.sh /

RUN chmod 777 /*.*


WORKDIR /app
COPY . /app
ENTRYPOINT ["/run.sh"]
