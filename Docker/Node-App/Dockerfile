FROM node:18

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y cron supervisor \
    && rm -rf /var/lib/apt/lists/*

COPY package*.json ./

RUN npm install
# RUN npm ci --only=production

COPY . .

RUN chmod +x scripts/update-file.sh

# Add supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add cronjob
RUN echo "*/2 * * * * root /usr/src/app/scripts/update-file.sh" >> /etc/crontab

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
