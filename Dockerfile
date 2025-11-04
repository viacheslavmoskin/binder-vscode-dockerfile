FROM jupyter/minimal-notebook:python-3.11

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git build-essential ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Node.js 22.17.1
ENV NODE_VERSION=22.17.1
RUN curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" \
 && mkdir -p /opt/node-v${NODE_VERSION} \
 && tar -xJf "node-v${NODE_VERSION}-linux-x64.tar.xz" -C /opt/node-v${NODE_VERSION} --strip-components=1 \
 && rm "node-v${NODE_VERSION}-linux-x64.tar.xz"
# Put this Node first on PATH (avoids touching existing /usr/local/bin or /opt/conda/bin)
ENV PATH="/opt/node-v${NODE_VERSION}/bin:${PATH}"


# Preinstall code-server
ENV CODE_SERVER_VERSION=4.89.1
RUN curl -fsSL -o /tmp/code-server.tgz \
      "https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-amd64.tar.gz" \
 && tar -xzf /tmp/code-server.tgz -C /opt \
 && ln -s "/opt/code-server-${CODE_SERVER_VERSION}-linux-amd64/bin/code-server" /usr/local/bin/code-server \
 && rm -f /tmp/code-server.tgz

USER ${NB_UID}

# JupyterLab + proxy integration
RUN pip install --no-cache-dir \
      "jupyter-server-proxy>=4,<5" \
      jupyter-codeserver-proxy \
      jupyterlab>=4 jupyterlab-lsp python-lsp-server[all] ipywidgets

# Explicitly enable (helps on Binder)
RUN jupyter server extension enable --py jupyter_server_proxy --sys-prefix

# Sanity in build logs
RUN python --version && jupyter lab --version && code-server --version && node -v && npm -v
