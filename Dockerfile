FROM ghcr.io/prefix-dev/pixi:noble

# copy source code, pixi.toml and pixi.lock to the container
COPY . /app
WORKDIR /app

# install the default env
RUN pixi install
# create the entrypoint
RUN echo 'pixi run jupyter lab --no-browser --ip=0.0.0.0 --port=8888' >> /entrypoint.sh

RUN apt install -y git vim emacs nano silversearcher-ag

WORKDIR /app
EXPOSE 8888

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
# CMD ["pixi", "run", "jupyter", "lab", "--no-browser", "--ip=0.0.0.0", "--port=8888"]
