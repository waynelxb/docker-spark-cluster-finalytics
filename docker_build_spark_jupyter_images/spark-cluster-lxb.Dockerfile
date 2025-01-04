FROM python:3.11-bullseye AS python-slim

# pkgs listed in requirements/spark_requirements.txt are installed in hetzner-base-lxb
FROM hetzner-base-lxb

COPY --from=python-slim /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=python-slim /usr/local/bin /usr/local/bin


# It seems HADOOP_HOME is not really used at all
ENV HADOOP_HOME="/opt/hadoop"
ENV SPARK_HOME="/opt/spark"
RUN mkdir -p ${HADOOP_HOME} && mkdir -p ${SPARK_HOME}

# Set SPARK_HOME as current work folder when dockerfile run here.
WORKDIR ${SPARK_HOME}

# Make sure the pyspark version in spark_requirements.txt is also 3.5.2
ARG spark_version=3.5.2

RUN curl https://archive.apache.org/dist/spark/spark-${spark_version}/spark-${spark_version}-bin-hadoop3.tgz -o spark-${spark_version}-bin-hadoop3.tgz \
    && tar xvzf spark-${spark_version}-bin-hadoop3.tgz --directory /opt/spark --strip-components 1 \
    && rm -rf spark-${spark_version}-bin-hadoop3.tgz

# ENV PATH="/opt/spark/sbin:/opt/spark/bin:${PATH}"
ENV PATH="${SPARK_HOME}/sbin:${SPARK_HOME}/bin:${PATH}"
ENV SPARK_VERSION=${spark_version}
ENV SPARK_MASTER="spark://spark-master:7077"
ENV SPARK_MASTER_HOST="spark-master"
ENV SPARK_MASTER_PORT="7077"
ENV PYSPARK_PYTHON="python3"

COPY ./conf/spark-defaults.conf ${SPARK_HOME}/conf

RUN chmod u+x /opt/spark/sbin/* && \
    chmod u+x /opt/spark/bin/*

COPY entrypoint.sh /opt/spark/entrypoint.sh
RUN sudo chmod +x /opt/spark/entrypoint.sh

ENTRYPOINT ["/opt/spark/entrypoint.sh"]