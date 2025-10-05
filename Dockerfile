#---------- Stage 1 : Builder ----------------------------------------------#

FROM python:3.12-slim-bullseye AS builder

WORKDIR /build

COPY requirements.txt .

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    software-properties-common \
    git && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get purge -y --auto-remove build-essential software-properties-common git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


#--------------- Stage 2 : Runtime ------------------------------------------#

FROM python:3.12-slim-bullseye

COPY --from=builder /usr/local/lib/python3.12/site-packages/ /usr/local/lib/python3.12/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/

RUN useradd -m -r appuser && \
    mkdir /app && \
    chown -R appuser /app

WORKDIR /app

COPY --chown=appuser:appuser src /app/

USER appuser

EXPOSE 8501
ENV PYTHONUNBUFFERED=1

ENTRYPOINT ["streamlit","run","app.py","--server.port=8501","--server.address=0.0.0.0"]
