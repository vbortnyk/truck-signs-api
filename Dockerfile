# Builder stage
FROM python:3.10-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    python3-dev \
    libpq-dev \
    zlib1g-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir --prefix=/install -r requirements.txt


# Runtime stage
FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    netcat-openbsd \
    libjpeg62-turbo \
    libpng16-16 \
    zlib1g \
    libfreetype6 \
    && rm -rf /var/lib/apt/lists/*

# create user ONCE
RUN useradd -m -u 1000 appuser

# copy dependencies first
COPY --from=builder /install /usr/local

# copy app
COPY . /app

RUN mkdir -p /app/staticfiles \
    && chmod +x /app/scripts/entrypoint.sh \
    && chmod +x /app/scripts/create_superuser.sh \
    && chown -R appuser:appuser /app

# switch to non-root
USER appuser

EXPOSE 8020

ENTRYPOINT ["/app/scripts/entrypoint.sh"]
