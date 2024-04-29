FROM okexchain/xlayer-dev:base_fork9_20240429

COPY . /app

EXPOSE 8080

CMD ["/bin/bash","-c","source /app/env/.env && source /root/.bashrc && /app/process.sh && http-server /app/output"]
