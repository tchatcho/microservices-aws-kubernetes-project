FROM python:3.11-slim

# Install system dependencies
RUN apt-get update -y && \
    apt-get install -y \
        build-essential \
        libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /analytics

# Copy requirements first (for caching efficiency)
COPY requirements.txt .

# Upgrade pip and install Python dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt

# Copy application code
COPY . .

# Expose the port the app
EXPOSE 5153

# Define default environment variables
ENV DB_USERNAME=myuser \
    DB_PASSWORD=mypassword \
    DB_HOST=127.0.0.1 \
    DB_PORT=5433 \
    DB_NAME=mydatabase

# Set the entrypoint
CMD ["python", "app.py"]
