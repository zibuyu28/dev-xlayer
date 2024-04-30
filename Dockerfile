FROM okexchain/xlayer-dev:base_fork9_20240429

COPY . /app

ARG BRANCH=release/v0.3.1

RUN if [ -z "$BRANCH" ]; then echo "BRANCH is not set!"; exit 1 fi && \
    cd /app/output && \
    git clone -b "$BRANCH" https://github.com/okx/xlayer-contracts.git && \
    cd xlayer-contracts && \
    npm install && \
    npm run compile

EXPOSE 8080

CMD ["/bin/bash","-c",". /app/env/.env && . /root/.bashrc && /app/process.sh && http-server /app/output"]
