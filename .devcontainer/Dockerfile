# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.187.0/containers/dotnet/.devcontainer/base.Dockerfile

# [Choice] .NET version: 5.0, 3.1, 2.1
ARG VARIANT="5.0"
FROM mcr.microsoft.com/vscode/devcontainers/dotnet:0-${VARIANT}

ARG INSTALL_NODE="true"
ARG NODE_VERSION="lts/*"
ARG INSTALL_AZURE_CLI="true"
ARG INSTALL_BICEP="true"
ARG INSTALL_POWERSHELL_CORE="true"
ARG INSTALL_DOCKER_CLI="true"
ARG INSTALL_KUBERNETES_CLI="true"
ARG INSTALL_HELM3="true"

RUN if [ "${INSTALL_NODE}" = "true" ]; then \
        su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; \
    fi

RUN if [ "true" = "true" ]; then \
        curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null \
        && AZ_REPO=$(lsb_release -cs) \
        && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list \
        && apt-get update \
        && apt-get -y install --no-install-recommends apt-transport-https curl ca-certificates lsb-release gnupg2 \
        && apt-get install -y azure-cli; \
    fi

RUN if [ "${INSTALL_BICEP}" = "true" ] && [ "true" = "true" ]; then \
            az bicep install; \
    fi

RUN if [ "${INSTALL_POWERSHELL_CORE}" = "true" ]; then \
        wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb \
        && dpkg -i packages-microsoft-prod.deb \
        && apt-get update \
        && apt-get install -y powershell; \
    fi

RUN if [ "${INSTALL_DOCKER_CLI}" = "true" ]; then \
        apt-get update \
        && apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common lsb-release \
        && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null \
        && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" \
        && apt-get update \
        && apt-get install -y docker-ce-cli; \
    fi

RUN if [ "${INSTALL_KUBERNETES_CLI}" = "true" ]; then \
        apt-get update && sudo apt-get install -y apt-transport-https \
        && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - \
        && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list \
        && apt-get update \
        && apt-get install -y kubectl; \
    fi

RUN if [ "${INSTALL_HELM3}" = "true" ]; then \
        curl https://helm.baltorepo.com/organization/signing.asc | sudo apt-key add - \
        && apt-get install apt-transport-https --yes \
        && echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list \
        && apt-get update \
        && apt-get install helm; \
    fi

RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*;