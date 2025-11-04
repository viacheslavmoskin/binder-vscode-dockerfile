# === Binder-friendly image with Python, Node.js 20, and VS Code UI ===
FROM jupyter/minimal-notebook:python-3.11

# Become root to install system deps
USER root

# Useful build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git build-essential ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# --- Install Node.js 20 (NodeSource) ---
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/*

# Back to the default notebook user
USER ${NB_UID}

# --- Python tooling + JupyterLab LSP ---
RUN pip install --no-cache-dir \
      jupyterlab>=4 \
      jupyterlab-lsp \
      python-lsp-server[all] \
      ipywidgets

# --- VS Code UI inside Jupyter ---
# jupyter-server-proxy + OpenVSCode Server integration
RUN pip install --no-cache-dir \
      jupyter-server-proxy \
      jupyter-vscode-proxy

# (Optional) common DS libs — comment out if you want it lean
# RUN pip install --no-cache-dir numpy pandas matplotlib scipy scikit-learn

# Verify versions in Binder build logs
RUN python --version && jupyter lab --version && node -v && npm -v

# Keep base entrypoint/CMD (Binder expects Jupyter to start)
