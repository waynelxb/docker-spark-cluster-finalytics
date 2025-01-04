# Use Python 3.11 base image with Debian Bullseye
FROM python:3.11-bullseye AS hetzner-base-lxb

# Define build arguments and environment variables
ARG shared_workspace=/opt/workspace
ENV SHARED_WORKSPACE=${shared_workspace}
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Install essential tools and dependencies
RUN apt-get update -y --fix-missing && \
    apt-get install -y --no-install-recommends \
        sudo \
        curl \
        vim \
        unzip \
        rsync \
        nano \
        openjdk-11-jdk \
        build-essential \
        software-properties-common \
        ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create shared workspace and set as working directory
RUN mkdir -p ${SHARED_WORKSPACE}
WORKDIR ${SHARED_WORKSPACE}
VOLUME ${SHARED_WORKSPACE}

# Set the default SHELL to bash. It should be set in Dockerfile, instead of docker-compose.yml 
# This setting has crucial impact on JupyterLab image, which is based on Hetzner-base
# With this setting, the interactive terminal within JupyterLab UI will be automatically stared with bash shell, instead of sh shell.
# (By default, the interactive shell inside a JupyterLab environment typically uses the sh shell 
# unless a specific shell (like bash or zsh) is explicitly configured in the container or environment. 
# This behavior depends on the base image and how the container is set up.)
ENV SHELL=/bin/bash

# Install Poetry
ENV POETRY_HOME=/root/.local
ENV PATH="$POETRY_HOME/bin:$PATH"
RUN curl -sSL https://install.python-poetry.org | python3 - && \
    # The following also works, but /root/.bashrc is only sourced by bash shell.
    # echo 'export PATH=$PATH:$POETRY_HOME/bin' >> /root/.bashrc
    # Add POETRY_HOME to PATH in /etc/profile, where python:3.11-slim saves the default PATH.
    # Add it to /etc/profile, the setting can be used for sh (the default JupyterLab container interactive shell) and bash.     
    echo 'export PATH=$PATH:$POETRY_HOME/bin' >> /etc/profile && \
# Create poetry env within project 
    poetry config virtualenvs.in-project true


# Copy and install Python dependencies for Spark
COPY requirements/spark_requirements.txt .
RUN pip3 install --upgrade pip && \
    pip3 install --no-cache-dir -r spark_requirements.txt

# Default command to keep the container running
CMD ["bash"]


