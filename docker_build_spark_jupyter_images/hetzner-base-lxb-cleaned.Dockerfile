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

# Install Poetry
ENV POETRY_HOME=/root/.local
ENV PATH="$POETRY_HOME/bin:$PATH"
RUN curl -sSL https://install.python-poetry.org | python3 - && \
    echo 'export PATH=$PATH:$POETRY_HOME/bin' >> /root/.bashrc

# Copy and install Python dependencies for Spark
COPY requirements/spark_requirements.txt .
RUN pip3 install --upgrade pip && \
    pip3 install --no-cache-dir -r spark_requirements.txt

# Default command to keep the container running
CMD ["bash"]


