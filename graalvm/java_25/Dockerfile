FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_VERSION=25

RUN apt-get update -y \
    && apt-get install -y curl tar \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-25.0.1/graalvm-community-jdk-25.0.1_linux-x64_bin.tar.gz \
    | tar -xz -C /opt \
    && ln -s /opt/graalvm-community-openjdk-25* /opt/graalvm

ENV JAVA_HOME=/opt/graalvm
ENV PATH="$JAVA_HOME/bin:$PATH"

RUN useradd -m -d /home/container -s /bin/bash container
WORKDIR /home/container
USER container
