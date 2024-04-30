FROM okexchain/xlayer-dev:base

COPY . /app

ARG BRANCH=""

RUN if [ "$BRANCH" = "" ]; then echo "BRANCH is not set!"; exit 1; fi && \
    cd /app && \
    git clone -b "$BRANCH" https://github.com/okx/xlayer-contracts.git && \
    cd xlayer-contracts && \
    npm install && \
    npm run compile

EXPOSE 8080

CMD ["/bin/bash","-c",". /app/env/.env && . /root/.bashrc && /app/process.sh && http-server /app/output"]
