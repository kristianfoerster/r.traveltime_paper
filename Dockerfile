FROM osgeo/grass-gis:8.5.0-ubuntu

USER root

RUN apt-get update && \
    apt-get install -y python3-pip python3-venv && \
    python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir \
        jupyterlab \
        notebook && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/venv/bin:${PATH}"

COPY . /home/jovyan