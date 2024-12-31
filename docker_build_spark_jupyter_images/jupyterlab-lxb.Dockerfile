FROM python:3.11-bullseye AS python-slim

# pkgs listed in requirements/spark_requirements.txt are installed in hetzner-base-lxb
FROM hetzner-base-lxb

COPY --from=python-slim /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=python-slim /usr/local/bin /usr/local/bin

# install pkgs listed in requirements/jupyterlab_requirements.txt 
COPY requirements/jupyterlab_requirements.txt .
RUN pip3 install --no-cache-dir -r jupyterlab_requirements.txt


# RUN curl -sSL https://install.python-poetry.org | python3 -  
# ENV POETRY_HOME=/root/.local
# ENV PATH=$PATH:$POETRY_HOME/bin
# RUN echo $PATH

WORKDIR ${SHARED_WORKSPACE}

# CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=
# Add a custom shell initialization script that ensures the environment variables are loaded properly when the JupyterLab terminal starts.
# Ensure Bash is used and loads .bashrc
# RUN echo "export PATH='/root/.local/bin:$PATH'" >> /root/.bashrc
# RUN echo 'export PATH=$PATH:$POETRY_HOME/bin' >> /root/.bashrc

CMD ["bash", "-c", "jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token="]