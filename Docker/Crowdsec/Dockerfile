FROM metabase/metabase:v0.53.9.1

RUN mkdir /data/ && \
    wget https://crowdsec-statics-assets.s3-eu-west-1.amazonaws.com/metabase_sqlite.zip && \
    unzip metabase_sqlite.zip -d /data/
