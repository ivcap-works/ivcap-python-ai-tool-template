FROM python:3.11.9-slim-bookworm AS builder

WORKDIR /app
RUN pip install -U pip
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt --force-reinstall

# Get service files
ADD tool-service.py  ./

# VERSION INFORMATION
ARG VERSION ???
ENV VERSION=$VERSION

# Command to run
ENTRYPOINT ["python",  "/app/tool-service.py"]