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


# Install spark module here to avoid repeated installation in jupyter and spark container
RUN pip3 install --upgrade pip 
RUN pip install --upgrade pip 

# Install poetry
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV POETRY_HOME=/root/.local
# ENV PATH=$POETRY_HOME/bin:$PATH

# Add a custom shell initialization script that ensures the environment variables are loaded properly when the JupyterLab terminal starts.
# Ensure Bash is used and loads .bashrc
RUN echo 'export PATH=$PATH:$POETRY_HOME/bin' >> /root/.bashrc

# Install required packages
COPY requirements/spark_requirements.txt .
RUN pip3 install --no-cache-dir -r spark_requirements.txt

CMD ["bash"]