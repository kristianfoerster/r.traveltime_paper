FROM osgeo/grass-gis:8.5.0-ubuntu

USER root

# Jupyter in a Python virtual environment
RUN apt-get update && \
    apt-get install -y python3-pip python3-venv && \
    python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir \
        jupyterlab \
        notebook \
        numpy \
        matplotlib && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/venv/bin:${PATH}"

# Allow the Binder user to build GRASS Addons
RUN chown -R ubuntu:ubuntu /usr/local/grass85

# Copy repository into the existing user's home directory
COPY . /home/ubuntu

# GRASS Addons are compiled with g.extension at runtime.
# The pre-built GRASS image is made writable for the Binder user.
RUN chown -R ubuntu:ubuntu /home/ubuntu

USER ubuntu

WORKDIR /home/ubuntu