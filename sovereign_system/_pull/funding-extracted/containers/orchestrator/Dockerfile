FROM python:3.11-slim
WORKDIR /app
RUN apt-get update && apt-get install -y git curl && rm -rf /var/lib/apt/lists/*
COPY . .
RUN pip install --no-cache-dir requests
CMD ["python3", "constellation-orchestrator.py", "status"]
