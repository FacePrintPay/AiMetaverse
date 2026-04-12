FROM python:3.11-slim
WORKDIR /app
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
COPY agent.sh .
RUN chmod +x agent.sh
CMD ["./agent.sh"]
