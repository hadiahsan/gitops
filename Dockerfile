FROM registry.access.redhat.com/ubi9/python-311:latest
WORKDIR /app
COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ .
EXPOSE 8080
CMD ["python", "app.py"]