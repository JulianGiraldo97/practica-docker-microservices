FROM jenkins/jenkins:lts

USER root

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Instalar Google Cloud SDK y el plugin de autenticación para GKE
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin kubectl

# Instalar Docker
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io

# Instalar QEMU para buildx multiplataforma
RUN apt-get update && apt-get install -y qemu-user-static

# Instalar buildx plugin (ya viene con Docker > 19.03, solo asegurate que esté activo)
RUN mkdir -p ~/.docker/cli-plugins/ && \
    curl -SL https://github.com/docker/buildx/releases/latest/download/buildx-v0.12.0.linux-amd64 -o ~/.docker/cli-plugins/docker-buildx && \
    chmod +x ~/.docker/cli-plugins/docker-buildx

# Instalar Maven
RUN apt-get install -y maven

# Agregar jenkins al grupo docker
RUN usermod -aG docker jenkins

USER jenkins
