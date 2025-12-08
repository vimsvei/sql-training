FROM postgres:17

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl unzip && \
    rm -rf /var/lib/apt/lists/*

COPY load_postgres_air.sh /usr/local/bin/load_postgres_air.sh
RUN chmod +x /usr/local/bin/load_postgres_air.sh

ENTRYPOINT ["/usr/local/bin/load_postgres_air.sh"]