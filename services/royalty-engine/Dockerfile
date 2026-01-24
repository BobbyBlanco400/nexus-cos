FROM python:3.11-slim
ARG N3XUS_HANDSHAKE
ENV N3XUS_HANDSHAKE=${N3XUS_HANDSHAKE}
WORKDIR /app
RUN if [ "$N3XUS_HANDSHAKE" != "55-45-17" ]; then echo "❌ N3XUS HANDSHAKE VIOLATION" && exit 1; fi
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app ./app
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "3000"]
