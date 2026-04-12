FROM python:3.11-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    git curl openssh-client ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Set permissions
RUN chmod +x *.sh

# Default command
CMD ["bash", "start.sh"]
