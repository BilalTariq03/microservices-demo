# Stage 1: Install dependencies
FROM python:3.12-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY requirements.txt ./
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Run
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV GEVENT_SUPPORT=True

WORKDIR /loadgen

COPY --from=builder /install /usr/local
COPY locustfile.py ./

ENTRYPOINT ["sh", "-c", "locust --host=http://${FRONTEND_ADDR} --headless -u ${USERS:-10} -r ${RATE:-1} 2>&1"]
