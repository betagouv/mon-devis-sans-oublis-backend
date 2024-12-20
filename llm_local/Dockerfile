# https://doc.scalingo.com/platform/app/filesystem

# Base image (Python or Ruby depending on your app)
FROM python:3.10-slim  # Or ruby:3.2 if it's a Rails app

# Install necessary tools and dependencies
RUN apt-get update && apt-get install -y curl

# Install Ollama CLI
RUN curl -fsSL https://ollama.com/install.sh | bash

# Add the binary to PATH if needed
ENV PATH="/root/.ollama/bin:$PATH"

RUN ollama pull llama3.2

# Copy your application code
WORKDIR /app
COPY . /app

# Install application dependencies (Python or Ruby gems)
RUN pip install -r requirements.txt  # Python
# Or for Ruby:
# RUN bundle install

# Expose the app's default port
EXPOSE 8000

# Command to start the application
CMD ["python", "app.py"]  # Adjust based on your app (e.g., Rails: ["rails", "s"])
