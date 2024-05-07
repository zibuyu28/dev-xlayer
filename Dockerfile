FROM office-registry.cn-hongkong.cr.aliyuncs.com/okbase/alinux3:230602.1-okg3

RUN curl -fsSL https://rpm.nodesource.com/setup_16.x | bash - && \
    yum install -y nodejs && \
    npm install -g npm@8.1.2 && \
    npm install -g solc@0.8.20 && \
    npm install http-server -g && \
    curl -L https://foundry.paradigm.xyz | bash && \
    . /root/.bashrc && foundryup

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
