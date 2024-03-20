FROM ubuntu:22.04

RUN echo "#################################################"
RUN echo "Ubuntu image that installs dependencies for BillTalksAI.com"
RUN echo "Git, Go, Hugo, NPM, Python, and dependencies."
RUN echo "Python is for scripting"

RUN echo "#################################################"
RUN echo "Set the timezone and suppress manual inputs"
RUN echo "(https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)"
ARG TIMEZONE="US/Pacific"
ARG DEBFRONTEND="noninteractive"
ENV TZ=$TIMEZONE \
    DEBIAN_FRONTEND=$DEBFRONTEND

RUN echo "#################################################"
RUN echo "Get the latest APT packages"
RUN echo "apt-get update"
RUN apt update && \
    apt-get -y update

RUN echo "#################################################"
RUN echo "Install and configure Git"
ARG GITUN="Bill Raymond"
ARG GITEMAIL="bill.raymond@cambermast.com"
RUN apt-get install -y git-all

RUN git config --global user.name "$GITUN" &&\
    git config --global user.email $GITEMAIL &&\
    git config --global init.defaultBranch main

RUN echo "#################################################"
RUN echo "Install pre-requisites"
RUN apt-get -y install --no-install-recommends \
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
    xz-utils

RUN echo "#################################################"
RUN echo "Install Python for any scripting needs PYVER 3.xx will insall 3.xx.1, 3.xx.2, etc"
ARG PYVER="3.11"
RUN apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get install -y python$PYVER \
    python3-pip

RUN echo "#################################################"
RUN echo "Set PYVER as the default Python interpreter"
RUN update-alternatives --install /usr/bin/python3 python /usr/bin/python$PYVER 1
RUN update-alternatives --set python /usr/bin/python$PYVER

RUN echo "#################################################"
RUN echo "Upgrade PIP"
RUN pip install --upgrade pip

RUN echo "#################################################"
RUN echo "Install Python dependencies"
RUN echo "Ex: to read markdown, YAML, and manipulate images"
RUN pip install \
        markdown \
        pyyaml \
        Pillow

RUN echo "#################################################"
RUN echo "Install Node.js and npm from NodeSource for faster web development"
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash - && \
          apt-get install -y nodejs \
          && npm install -g npm@latest \
          sass

RUN echo "#################################################"
RUN echo "Install Go (Golang)"
ENV GO_VERSION 1.22.1
ENV GOROOT /usr/local/go
ENV GOPATH /go
ENV PATH $GOPATH/bin:$GOROOT/bin:$PATH

RUN wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz -O go.tar.gz && \
    tar -xzf go.tar.gz && \
    mv go /usr/local

RUN echo "#################################################"
RUN echo "Download and install Dart Sass"
ENV DART_SASS_VERSION 1.54.5
RUN wget https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz -O dart-sass.tar.gz && \
    tar -xzf dart-sass.tar.gz -C /usr/local && \
    ln -s /usr/local/dart-sass/sass /usr/local/bin/sass

RUN echo "#################################################"
RUN echo "Download and install Hugo Extended"
ENV HUGO_VERSION 0.124.0
RUN wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-ARM64.tar.gz -O hugo.tar.gz && \
    tar -xzf hugo.tar.gz -C /usr/local/bin && \
    rm -rf hugo.tar.gz

RUN echo "#################################################"
RUN echo "Clean up caches"
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    npm cache clean --force && \
    find / -type d -name __pycache__ -prune -exec rm -rf {} \;
