FROM osgeo/grass-gis:8.5.0-ubuntu

USER root

# Jupyter
RUN apt-get update && \
    apt-get install -y python3-pip && \
    pip3 install --no-cache-dir jupyterlab notebook && \
    rm -rf /var/lib/apt/lists/*

# Binder user
ARG NB_USER=jovyan
ARG NB_UID=1000

ENV USER=${NB_USER}
ENV NB_UID=${NB_UID}
ENV HOME=/home/${NB_USER}

RUN useradd -m -s /bin/bash -u ${NB_UID} ${NB_USER}

# Repository contents
COPY . ${HOME}

RUN chown -R ${NB_UID}:${NB_UID} ${HOME}

USER ${NB_USER}

WORKDIR ${HOME}