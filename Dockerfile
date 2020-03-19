# Dockerfile may have two Arguments: tag, branch
# tag - tag for the Base image, (e.g. 1.10.0-py3 for tensorflow)
# pyVer - python versions as 'python' or 'python3'
# branch - user repository branch to clone (default: master, other option: test)
# jlab - if to insall JupyterLab (true) or not (false, default)
#
# To build the image:
# $ docker build -t <dockerhub_user>/<dockerhub_repo> --build-arg arg=value .
# or using default args:
# $ docker build -t <dockerhub_user>/<dockerhub_repo> .
#
# Be Aware! For the Jenkins CI/CD pipeline, 
# input args are defined inside the Jenkinsfile, not here!
#

ARG tag=1.12.0

# Base image, e.g. tensorflow/tensorflow:1.12.0-py3
FROM tensorflow/tensorflow:${tag}

LABEL maintainer='G.Cavallaro (FZJ), M.Goetz (KIT), V.Kozlov (KIT), A.Grupp (KIT)'
LABEL version='0.3.0'
# 2D semantic segmentation (Vaihingen dataset)

# it is still python2 code...
ARG pyVer=python3

# What user branch to clone (!)
ARG branch=api_v2

# If to install JupyterLab
ARG jlab=false

# Install ubuntu updates and python related stuff
# link python3 to python, pip3 to pip, if needed
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends \
         git \
         curl \
         wget \
         $pyVer-setuptools \
         $pyVer-pip \
         $pyVer-wheel && \ 
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/* && \
    if [ "$pyVer" = "python3" ] ; then \
       if [ ! -e /usr/bin/pip ]; then \
          ln -s /usr/bin/pip3 /usr/bin/pip; \
       fi; \
       if [ ! -e /usr/bin/python ]; then \
          ln -s /usr/bin/python3 /usr/bin/python; \
       fi; \
    fi && \
    python --version && \
    pip --version


# Set LANG environment
ENV LANG C.UTF-8

# Set the working directory
WORKDIR /srv

# install rclone
RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.deb && \
    dpkg -i rclone-current-linux-amd64.deb && \
    apt install -f && \
    mkdir /srv/.rclone/ && touch /srv/.rclone/rclone.conf && \
    rm rclone-current-linux-amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

ENV RCLONE_CONFIG=/srv/.rclone/rclone.conf

# Install DEEPaaS from PyPi
# Install FLAAT (FLAsk support for handling Access Tokens)
#RUN pip install --no-cache-dir \
#        'deepaas>=1.0.0' \
#        flaat && \
#    rm -rf /root/.cache/pip/* && \
#    rm -rf /tmp/*
    
RUN git clone master https://github.com/indigo-dc/deepaas && \
 	cd deepaas && \
 	pip install --no-cache-dir -U . && \
 	rm -rf /root/.cache/pip/* && \
 	rm -rf /tmp/* && \
 	cd ..

# Disable FLAAT authentication by default
ENV DISABLE_AUTHENTICATION_AND_ASSUME_AUTHENTICATED_USER yes

# Install DEEP debug_log scripts:
RUN git clone https://github.com/deephdc/deep-debug_log /srv/.debug_log

# Install JupyterLab
ENV JUPYTER_CONFIG_DIR /srv/.jupyter/
# Necessary for the Jupyter Lab terminal
ENV SHELL /bin/bash
RUN if [ "$jlab" = true ]; then \
       pip install --no-cache-dir jupyterlab ; \
       git clone https://github.com/deephdc/deep-jupyter /srv/.jupyter ; \
    else echo "[INFO] Skip JupyterLab installation!"; fi

# Install user app:
RUN git clone -b $branch https://github.com/silkedh/semseg_vaihingen.git && \
    cd  semseg_vaihingen && \
    pip install --no-cache-dir -e . && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/* && \
    cd ..


# Open DEEPaaS port
EXPOSE 5000

# Open Monitoring  and Jupyter ports
EXPOSE 6006 8888

# Account for OpenWisk functionality (deepaas 0.5.1)
CMD ["deepaas-run", "--openwhisk-detect", "--listen-ip", "0.0.0.0", "--listen-port", "5000"]
