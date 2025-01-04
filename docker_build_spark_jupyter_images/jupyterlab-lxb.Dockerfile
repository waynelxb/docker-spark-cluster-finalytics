FROM python:3.11-bullseye AS python-slim

# pkgs listed in requirements/spark_requirements.txt are installed in hetzner-base-lxb
FROM hetzner-base-lxb

COPY --from=python-slim /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=python-slim /usr/local/bin /usr/local/bin

# Install pkgs listed in requirements/jupyterlab_requirements.txt 
COPY requirements/jupyterlab_requirements.txt .
RUN pip3 install --no-cache-dir -r jupyterlab_requirements.txt

# The default SHELL is sh, instead of bash, we need to set it /bin/bash, also it has to be set in Dockerfile, instead of docker-compose.yml 
# ENV SHELL=/bin/bash

WORKDIR ${SHARED_WORKSPACE}

# When the container is started, CMD will automatically run, launching JupyterLab configured for use in environments 
# bash is the shell being invoked.
# The -c option tells bash to execute the command that follows as a string.
CMD ["bash", "-c", "jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token="]
