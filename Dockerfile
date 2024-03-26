FROM ubuntu:23.10

RUN echo "#################################################"
ARG DEBFRONTEND="noninteractive"
ENV DEBIAN_FRONTEND=$DEBFRONTEND

RUN echo "#################################################"
RUN echo "Get the latest APT packages"
RUN echo "apt-get update"
RUN apt update && \
    apt-get -y update

RUN echo "#################################################"
RUN echo "Install pre-requisites, preferential tools, and generate en_US.UTF-8"
RUN apt-get install -y --no-install-recommends \
    wget \
    curl \
    build-essential \
    libssl-dev \
    libyaml-dev \
    zlib1g-dev \
    apt-utils \
    jq \
    ca-certificates \
    tar \
    xz-utils \
    tzdata \
    locales && \
    locale-gen en_US.UTF-8
    
RUN echo "#################################################"
RUN echo "Set the locale and timezone"
RUN echo "(https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)"
ARG TIMEZONE="America/Los_Angeles"
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TZ=$TIMEZONE
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata 2>/dev/null

RUN echo "#################################################"
RUN echo "Install specific versions of Node.js, npm, and Dart SASS"
ARG NODE_VERSION=21.x
ENV NPM_VERSION=10.5.0
ENV SASS_VERSION=1.72.0

RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION | bash - && \
    apt-get update && apt-get install -y nodejs && \
    npm install -g npm@$NPM_VERSION sass@$SASS_VERSION

RUN echo "#################################################"
RUN echo "Install a specific version of Go (golang) for the current architetcure"
ARG GO_VERSION=1.22.1
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
RUN apt-get update && \
    apt-get install -y curl git build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    curl -L "https://golang.org/dl/go${GO_VERSION}.linux-$(dpkg --print-architecture).tar.gz" | tar -C /usr/local -xz

RUN echo "#################################################"
RUN echo "Install a specific version of Hugo for the current architetcure"
ARG HUGO_VERSION=0.124.1
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64) HUGO_ARCH="64bit" ;; \
        aarch64) HUGO_ARCH="arm64" ;; \
        arm*) HUGO_ARCH="arm" ;; \
        *) echo "Unsupported architecture" && exit 1 ;; \
    esac && \
    HUGO_DOWNLOAD="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-${HUGO_ARCH}.tar.gz" && \
    curl -Ls $HUGO_DOWNLOAD | tar -xz -C /usr/local/bin hugo

RUN echo "#################################################"
RUN echo "Install Python for any scripting needs PYVER 3.xx will insall 3.xx.1, 3.xx.2, etc"
ENV PYVER="3.11"
RUN apt-get update && \
    apt-get install -y \
    software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get install -y \
    python$PYVER \
    python3-pip \
    python3-venv

RUN echo "#################################################"
RUN echo "Set PYVER as the default Python interpreter"
RUN update-alternatives --install /usr/bin/python3 python /usr/bin/python$PYVER 1
RUN update-alternatives --set python /usr/bin/python$PYVER

RUN echo "#################################################"
RUN echo "Create and use a Python3 virtual environment (venv)"
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN echo "#################################################"
RUN echo "Upgrade PIP"
RUN pip install --upgrade pip

RUN echo "#################################################"
RUN echo "Install Python dependencies"
RUN echo "Ex: to read markdown, YAML, and manipulate images"
RUN pip install \
        pyyaml \
        Pillow

RUN echo "#################################################"
RUN echo "Clean up caches"
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    npm cache clean --force && \
    find / -type d -name __pycache__ -prune -exec rm -rf {} \;
