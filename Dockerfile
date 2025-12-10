FROM certbot/certbot

RUN apk update && apk add openssh sshpass mandoc man-pages cronie \
    && mkdir -p /var/spool/cron \
    && mkdir -p /work \
    && echo '*/1 * * * * echo "hello world"' > /var/spool/cron/root \
    && chmod 600 /var/spool/cron/root \
    && rm -rf /tmp/* /var/tmp/*

RUN cat < "EOF" > /CronRootSync.sh
#! /bin/bash

echo "*/1 * * * * sleep 0s;/CronRootSync.sh" > /tmp/cron_root_tmp;
echo "*/1 * * * * sleep 10s;/CronRootSync.sh" >> /tmp/cron_root_tmp;
echo "*/1 * * * * sleep 20s;/CronRootSync.sh" >> /tmp/cron_root_tmp;
echo "*/1 * * * * sleep 30s;/CronRootSync.sh" >> /tmp/cron_root_tmp;
echo "*/1 * * * * sleep 40s;/CronRootSync.sh" >> /tmp/cron_root_tmp;
echo "*/1 * * * * sleep 50s;/CronRootSync.sh" >> /tmp/cron_root_tmp;
if [ -e "/data/cron_root.txt" ]; then
    cat /data/cron_root.txt >> /tmp/cron_root_tmp;
fi

if [ `md5sum /tmp/cron_root_tmp | awk -F\  '{print $1}'` != `md5sum /var/spool/cron/root | awk -F\  '{print $1}'` ]; then
    cat /tmp/cron_root_tmp > /var/spool/cron/root;
    echo "CronRootSync: FileChanged";
    exit;
fi
echo "CronRootSync: FileNoChange";
EOF

RUN cat < "EOF" > /run.sh
#! /bin/bash

# set the timezone
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo Asia/Shanghai > /etc/timezone

/bin/bash /CronRootSync.sh;
/usr/sbin/crond -n -x proc 2>&1 | stdbuf -o0 grep '^log_it' | stdbuf -o0 grep -Ev "CronRootSync.sh" | stdbuf -o0 grep -Ev "FileNoChange"
EOF

RUN cat < "EOF" > /data/cron_root.txt
*/1 * * * * source /root/.bashrc; echo "node_version: `node -v`"
EOF

RUN chmod 777 /*.*


WORKDIR /app
COPY . /app
CMD /run.sh
