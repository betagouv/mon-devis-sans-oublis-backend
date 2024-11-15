# Use an official lightweight Python image
FROM python:3.9-slim-buster

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_DEFAULT_TIMEOUT=100 \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    HF_HOME=/app/huggingface_cache

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies for Apple Silicon compatibility (macOS M2)
RUN pip install --upgrade pip setuptools wheel

# Copy requirements file
COPY requirements.txt /app/requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code (if applicable)
COPY . /app

RUN mkdir -p $HF_HOME && chmod -R 777 $HF_HOME
RUN mkdir -p ~/.cache && chmod -R 777 ~/.cache

# Set the default command to run
CMD ["python", "-i", "app.py"]
