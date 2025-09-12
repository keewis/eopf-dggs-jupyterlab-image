FROM ghcr.io/prefix-dev/pixi:noble

# copy source code, pixi.toml and pixi.lock to the container
COPY . /app
WORKDIR /app

# install the default env
RUN pixi install
# Create the shell-hook bash script to activate the environment
RUN pixi shell-hook > /shell-hook.sh

# extend the shell-hook script to run the command passed to the container
RUN echo 'exec "$@"' >> /shell-hook.sh

RUN apt install -y git vim emacs nano silversearcher-ag

COPY --from=build /shell-hook.sh /shell-hook.sh
WORKDIR /app
EXPOSE 8888

# set the entrypoint to the shell-hook script (activate the environment and run the command)
# no more pixi needed in the prod container
ENTRYPOINT ["/bin/bash", "/shell-hook.sh"]

CMD ["pixi", "run", "jupyter", "lab", "--no-browser", "--ip=0.0.0.0", "--port=8888"]
