FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y curl tar \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-21.0.2/graalvm-community-jdk-21.0.2_linux-x64_bin.tar.gz \
    | tar -xz -C /opt \
    && ln -s /opt/graalvm-community-openjdk-21* /opt/graalvm

ENV JAVA_HOME=/opt/graalvm
ENV PATH="$JAVA_HOME/bin:$PATH"

RUN groupadd -g 998 container \
    && useradd -u 998 -g 998 -m -d /home/container -s /bin/bash container

WORKDIR /home/container
USER container
