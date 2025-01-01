FROM python:3.11-bullseye AS hetzner-base-lxb

ARG shared_workspace=/opt/workspace

# Setup basic environment and python
RUN mkdir -p ${shared_workspace} && \
    apt-get update -y --fix-missing && \
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


# Set JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Set SHARED_WORKSPACE environment variable
ENV SHARED_WORKSPACE=${shared_workspace}
VOLUME ${shared_workspace}


# Install poetry
# ENV POETRY_HOME="/root/.local/share/pypoetry"
ENV POETRY_HOME=/root/.local
ENV PATH="$POETRY_HOME/bin:$PATH"

# # Ensure Bash is used and loads .bashrc
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=${POETRY_HOME} python3 - && \
    echo 'export PATH=$PATH:$POETRY_HOME/bin' >> /root/.bashrc


# Install required packages
COPY requirements/spark_requirements.txt .
RUN pip3 install --upgrade pip && \
    pip3 install --no-cache-dir -r spark_requirements.txt

CMD ["bash"]